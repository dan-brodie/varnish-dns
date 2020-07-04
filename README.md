# varnish-dns
docker image for debian with varnish and dynamicdns vmod

Basic entrypoint and vcl take from official varnish container

build
`docker build -t varnish:local .`

test
```
docker run -d \
  -it \
  --name varnish-test \
  --mount type=bind,source="$(pwd)"/default.vcl,target=/etc/varnish/default.vcl \
  varnish:local
```