#!/bin/sh

# Based on script published on
# https://www.bloglibre.net/2016/01/09/installation-et-configuration-de-apt-cacher-ng

PROXY_HOST=arion
PROXY_PORT=3142

nc -zw1 $PROXY_HOST $PROXY_PORT \
    && echo http://$PROXY_HOST:$PROXY_PORT/ \
    || echo DIRECT
