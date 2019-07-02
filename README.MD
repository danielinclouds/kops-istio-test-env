# kops-istio-test-env

### Start cluster
To start new cluster with `helm` and `istio` installed run
```sh
./start.sh
```

To export variables for working with kops run
```sh
source ./env.sh
```

### Install addons (Istio with Kiali)
To install addons first create cluster; then install addon.
```sh
./start.sh
pushd addons
    ./install-istio-with-kiali.sh
popd
```

### Destroy cluster
To cleanup environment run 
```sh
./stop.sh
```
