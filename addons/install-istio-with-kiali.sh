#!/bin/bash
set -e

helm upgrade istio istio.io/istio \
    --install \
    --wait \
    --namespace istio-system \
    --values kiali-values.yaml 