# Documentation: https://just.systems/man/en/

set shell := ["bash", "-euo", "pipefail", "-c"]

# To override the value of VARIABLE, run: just --set VARIABLE VALUE TARGET

OWNER := "jceb"
IMAGE := "sogo"
TAG := `date +%y%m%d`

# Print this help
help:
    @just -l

# Build image
build:
    docker build -t "{{ OWNER }}/{{ IMAGE }}:latest" -t "{{ OWNER }}/{{ IMAGE }}:{{ TAG }}" .

# Build image
build-force:
    docker build --no-cache -t "{{ OWNER }}/{{ IMAGE }}:latest" -t "{{ OWNER }}/{{ IMAGE }}:{{ TAG }}" .

# Push image
push:
    docker push "{{ OWNER }}/{{ IMAGE }}:{{ TAG }}"
    docker push "{{ OWNER }}/{{ IMAGE }}:latest"
