# ddns_cloudflare
Shell script that updates cloudflare's DNS record to match your public IP. All in a Docker container and ready to deploy in kubernetes. Docker image is for armhf architecture (runs in a raspberry pi).

Credits to [steasdal](https://github.com/steasdal/ddclient-alpine) for most of the yaml configuration files.

Docker image available in [Docker Hub](https://cloud.docker.com/repository/docker/fsicardir/ddns_cloudflare).

### Build image:
Open the console and type: 
`docker image build . -t <tag>`

### Deploy in kubernetes cluster:
- Change the fields in _cloudflare-secret.yaml_ to match your own data. Remember it must be encoded in base64 (`echo -n yourRawDataString | base64`).
- Create the secret: `kubect apply -f ./cloudflare-secret.yaml`.
- We don't want to update the DNS record if it hasn't changed, so we need to save the IP address after we update it. In order to do this, you need to persist it somehow.
An NFS server running in one of the nodes seems to be the easier approach. You will need to change the _path_ and _server_ fields in _ddns-persistent-volume.yaml_.
- Then we create the persistent volume: `kubect apply -f ./ddns-persistent-volume.yaml`.
- Finally, we deploy our application: `kubectl apply -f ./ddns-cloudflare-deployment.yaml`, and that's it!.
- Run `kubectl get all -l 'app=ddns'` and check if all is ready.
- You can see the logs with `kubectl logs $(kubectl get deployments -l 'app=ddns' -o name)`
