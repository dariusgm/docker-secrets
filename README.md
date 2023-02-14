# docker-secrets

This example shows, how to reverse engineer secrets from a docker image, when they are placed inside a layer.

## Pre-Requirement

Consider you have something that you need to download software.
But as you are in a company network, you need to go via a proxy with your
personal credentials.
After you downloaded the software, you remove the credentials from the layer and are done.
Unfortunatly, this is not a save method to handle secrets.

In this demo project, you can see the problem and also the solution how to prevent it.

## Dockerfile
This Dockerfile is the one that exposes secrets via its layer.
* Add personal credentials via `COPY`
* Download required software
* Remove credentials

Than we will analyse the layer and are able to restore the credentials.

Build if with:
```bash
docker build -t docker-secrets .
```

you will not find the credentials when you run the image
```bash
docker run -it docker-secrets ls
```

But they are still present.
Docker layers are compressed tar archives that you can expect.
For easy access, a tool was created for that purpose: `dive`.
You can download it from github.com: https://github.com/wagoodman/dive
With dive you can search for all changes in each layer, so you know what you are looking for
to extracted. As we just created the image, we search the `/root/secrets.json` file.

But you can't really take a look at the **content** of the file.


export the image as tar archive
```bash
docker save docker-secrets -o docker-secrets.tar
```
unpack the tar archive
```bash
tar xf docker-secrets.tar
```

Search for the file you are interested in via `dive`
```bash
export FILENAME="secrets.json"
for layer in */layer.tar; do tar -tf $layer | grep $FILENAME && echo $layer; done
```

now you have the layer hashes where the file is placed. In my example:
```bash
root/.wh.secrets.json
7ffab2fd67ed1e5948017e7856340e6629baf1a486f6cbd713db55f2a66517b5/layer.tar
root/secrets.json
bd6f414da0ffb5996c9ddb9e1e8da783256666d15ec802b1045941103803513a/layer.tar
```

Go get the content:
```bash
tar xf bd6f414da0ffb5996c9ddb9e1e8da783256666d15ec802b1045941103803513a/layer.tar root/secrets.json     
```

Now you will find the extracted secrets file under root/secrets.json.

To prevent secrets to go out, use volumes instead as they are not part of the docker layers.

