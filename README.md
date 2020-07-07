# varnish-dns
docker image for Alpine with varnish and dynamicdns vmod

Basic entrypoint and vcl take from official varnish container

build
`docker build -t varnish:local .`

test
```
docker run -d \
  -it \
  --name varnish \
  --mount type=bind,source="$(pwd)"/default.vcl,target=/usr/local/etc/varnish/default.vcl \
  varnish:local
```

# features

- switched on logging using apache pattern with varnishncsa

- moved vmod compilation stage into seperate container for smallest possible final image