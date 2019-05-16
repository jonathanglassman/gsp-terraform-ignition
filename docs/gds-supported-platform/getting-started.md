# Getting started

## Set up

1. Install and configure Golang

1. Run the following in the command line to install [homebrew](https://brew.sh/):

    ```
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ```

1. Run the following in the command line to install `kubectl` and `helm`:

    ```
    brew install kubernetes-cli
    brew install kubernetes-helm
    ```

1. Run the following the command line to install [`kind`]():

1. Clone the GSP repo:

    ```
    git clone https://github.com/alphagov/gsp-terraform-ignition.git
    ```

1. Run the following to create a local GSP cluter:

    ```
    ./scripts/gsp-local.sh create
    ```

1. Configure `kubectl` to use the local GSP cluster:

		```
		export KUBECONFIG="$(kind get kubeconfig-path --name="gsp-local")"
		```

1. Run the following to check that you can access your local cluster using [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

    ```
    kubectl get nodes
    ```

## Create a Helm chart

1. Clone the GOV.UK Prototype Kit:

```
git clone https://github.com/alphagov/govuk-prototype-kit
```

1. Create a `Dockerfile` for the prototype-kit:

```
FROM node:8.12-alpine

ADD . /app
WORKDIR /app

ARG COLLECT_USAGE_DATA=true

RUN npm install
RUN echo "{\"collectUsageData\": $COLLECT_USAGE_DATA}" > usage-data-config.json

EXPOSE 3000
CMD ["npm", "start"]
```

1. Build, test and copy the image into the cluster:

```
docker build . --tag prototype-kit:latest
docker run --publish 3000:3000 prototype-kit:latest
kind load docker-image --name gsp-local prototype-kit:latest
```

The GDS Supported Platform uses a packaging format called [Helm charts](https://helm.sh/docs/developing_charts/). A chart is a collection of files that describe a related set of Kubernetes resources.

You create Helm charts as files in a directory. These files are then packaged into versioned archives that users can deploy.

1. Create a `chart/` directory inside `govuk-prototype-kit`

1. Create a `Chart.yaml` file in the this directory with the following code:

    ```
    apiVersion: v1
    appVersion: "1.0"
    description: GOV.UK Prototype Kit
    name: prototype-kit
    version: 0.1.0
    ```

    This file defines metadata about the chart.

1. Create a `templates` directory in the `chart/` directory. This directory contains all Kubernetes object definitions.

## Create a Kubernetes Deployment object

You run an app by creating a [Kubernetes Deployment object](https://kubernetes.io/docs/concepts/#kubernetes-objects). This object defines your app and its routes, databases and all other relevant information. You describe a Deployment in a YAML file.

1. Create a `deployment.yaml` file in the `templates` directory. The following example uses an [nginx](https://hub.docker.com/_/nginx/) container image called `myapp`. Replace this nginx container image with your app image:

    ```
    apiVersion: apps/v1beta2
    kind: Deployment
    metadata:
      name: {{ .Release.Name }}-web
      labels:
        app.kubernetes.io/name: web
        app.kubernetes.io/instance: {{ .Release.Name }}
    spec:
      replicas: {{ .Values.replicas }}
      selector:
        matchLabels:
          app.kubernetes.io/name: web
          app.kubernetes.io/instance: {{ .Release.Name }}
      template:
        metadata:
          labels:
            app.kubernetes.io/name: web
            app.kubernetes.io/instance: {{ .Release.Name }}
        spec:
          containers:
            - name: prototype-kit
              image: "prototype-kit:latest"
              ports:
                - name: http
                  containerPort: 3000
                  protocol: TCP
    ```

    Helm automatically populates the `{{ .Release.Name }}` and `{{ .Values.replicas }}` variables when you render the chart.

1. Run the following command in the root directory to render the chart and send the output to an `output` directory:

    ```
    mkdir output
    helm template --name example --output-dir=output .
    ```

1. Check `stdout` to see if the chart rendered correctly.

1. Run the following command to install the contents of the `output` dir to the Minikube cluster:

    ```
    kubectl apply -R -f output/
    ```
1. Run the following to list the Deployments installed in the cluster:

    ```
    kubectl get deployments
    ```


1. Run the following to check that the pods are running:

    ```
    kubectl get pods
    ```
    _Is this necessary to do at this point?_

## Create a service

By default, your apps are not accessible to the public. To expose them to the public, you must set up a [VirtualService]() and `port-forward` to the cluster's Ingress Gateway.

Setting up a VirtualService creates a stable endpoint that acts like an internal load balancer to send traffic to your Deployment's Pods.

1. Create a `service.yaml` file in the `templates` directory with the following code:

    ```
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ .Release.Name }}-APP_NAME
      labels:
        app.kubernetes.io/name: APP_NAME
        app.kubernetes.io/instance: {{ .Release.Name }}
    spec:
      type: ClusterIP
      ports:
        - port: 80
          targetPort: http
          protocol: TCP
          name: http
      selector:
        app.kubernetes.io/name: APP_NAME
        app.kubernetes.io/instance: {{ .Release.Name }}
    ```
    Helm automatically populates the `{{ .Release.Name }}` variable when you render the chart.


1. Render your template again:

    ```
    helm template --name=example --output-dir=output .
    ```

1. Re-apply the template to the cluster:

    ```
    kubectl apply -R -f output/
    ```

1. Use `kubectl port-forward` to tunnel to the Ingress Gateway:

    ```
    sudo --preserve-env kubectl port-forward service/istio-ingressgateway -n istio-system 80:80
    ```

## Connect to GOV.UK Prototype Kit

1. Open a browser.

1. Naviate to `http://prototype-kit.local.govsandbox.uk`

## Destroy cluster

Run the following command to destroy the cluster:

		```
		./scripts/gsp-local.sh delete
		```

### References

_do we need these references or any others?_

|Topic|Description|
|----|-----------|
|[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)| kubernetes command line tool|
|[kubernetes](https://kubernetes.io/docs/home/?path=users&persona=app-developer&level=foundational)| k8s |
|[helm](https://docs.helm.sh/)| helm package manager for kubernetes|
|[jq](https://stedolan.github.io/jq/manual/)| json wrangling filter |
|[minikube](https://github.com/kubernetes/minikube)|local kubernetes |
|[virtualbox](https://www.virtualbox.org/manual/UserManual.html)|hypervisor
