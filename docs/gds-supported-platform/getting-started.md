# Getting started

## Set up Minikube

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

The GDS Supported Platform uses a packaging format called [Helm charts](https://helm.sh/docs/developing_charts/). A chart is a collection of files that describe a related set of Kubernetes resources.

You create Helm charts as files in a directory. These files are then packaged into versioned archives that users can deploy.

1. Create a root directory in your GitHub repository. This directory will contain the chart.

1. Create a `Chart.yaml` file in the root directory with the following code:

    ```
    apiVersion: v1
    appVersion: "1.0"
    description: CHART_DESCRIPTION
    name: CHART_NAME
    version: 0.1.0
    ```

    This file defines metadata about the chart.

1. Create a `templates` directory in the root directory. This directory contains all Kubernetes object definitions.

1. Create a `values.yaml` file in the root directory. This file sets the default values for your desired chart variables.

## Create a Kubernetes Deployment object

You run an app by creating a [Kubernetes Deployment object](https://kubernetes.io/docs/concepts/#kubernetes-objects). This object defines your app and its routes, databases and all other relevant information. You describe a Deployment in a YAML file.

1. Create a `deployment.yaml` file in the `templates` directory. The following example uses an [nginx](https://hub.docker.com/_/nginx/) container image called `myapp`. Replace this nginx container image with your app image:

    ```
    apiVersion: apps/v1beta2
    kind: Deployment
    metadata:
      name: {{ .Release.Name }}-myapp
      labels:
        app.kubernetes.io/name: myapp
        app.kubernetes.io/instance: {{ .Release.Name }}
    spec:
      replicas: {{ .Values.replicas }}
      selector:
        matchLabels:
          app.kubernetes.io/name: myapp
          app.kubernetes.io/instance: {{ .Release.Name }}
      template:
        metadata:
          labels:
            app.kubernetes.io/name: myapp
            app.kubernetes.io/instance: {{ .Release.Name }}
        spec:
          containers:
            - name: myappcontainer
              image: "nginx:latest" #Replace this with your app image
              ports:
                - name: http
                  containerPort: 80
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

By default, your apps are not accessible to the public. To expose them to the public, you must set up a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) and an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) into the Kubernetes cluster.

Setting up a Service creates a stable endpoint that acts like an internal load balancer to send traffic to your Deployment's Pods.

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

1. Use `kubectl port-forward` to tunnel to the `Service` endpoint to check that the endpoint is working:

    ```
    kubectl port-forward service/example-myapp 8080:80
    ```

## Create an Ingress

You must define an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to route public internet traffic to the stable endpoint you created when you set up the Service.

1. Create a `ingress.yaml` file in the `templates` directory with the following code:

    ```
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: {{ .Release.Name }}-myapp
      annotations:
          nginx.ingress.kubernetes.io/rewrite-target: "/"
    spec:
      rules:
      - host:  {{ .Release.Name }}.{{ .Values.global.cluster.domain }}
        http:
          paths:
          - backend:
              serviceName: example-myapp
              servicePort: 80
            path: /
    ```

1. Render your template again:

    ```
    helm template --name=example --output-dir=output .
    ```

1. Re-apply the template to the cluster:

    ```
    kubectl apply -f -
    ```
1. Check that you created the Ingress successfully:

    ```
    kubectl get ingress
    ```

    Example output:

    ```
    kubectl get ingress
    NAME            HOSTS           ADDRESS     PORTS   AGE
    example-myapp   www.myapp.com   10.0.2.15   80      3m31s
    ```

## Test that the Ingress is working

_Do we need this bit? Have not changed content from original_

Our ingress route should now be working and routing traffic for the `www.myapp.com` host from the exposed minikube IP to our Service and on to our Pods running nginx... we can test this using curl:

```
curl -k -H 'Host: www.myapp.com' http://$(minikube ip)/
```

The `minikube ip` command will return the IP address of the minikube virtual machine, which is the ingress point. We add a `Host: www.myapp.com` header to the request so that our request is correctly routed.


which should show the "Thank you for using nginx" message!

```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```

You can check the logs of your application using

```
kubectl logs -f example-myapp-768cd7d675-zmr6vkubectl
```

The `-f` switch steams updates from the log as they happen and the pod name is the value you find in the output from `kubectl get pods`

```
72.17.0.2 - - [10/Jan/2019:11:10:12 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36" "192.168.99.1"
172.17.0.2 - - [10/Jan/2019:11:12:44 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.54.0" "192.168.99.1"
172.17.0.2 - - [10/Jan/2019:11:13:03 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.54.0" "192.168.99.1"
```

## Scale deployment up to ten nginx instances

_Do we need this bit? Have not changed content from original_

Now lets scale our deployment up to ten nginx instances. We can override the replicas setting during the templating as folllows:

```
helm template --name=example --set-string replicas=10 .
```

variables passed using `--set-string` override the default in the `values.yaml` file.
Note the default replicas setting is now set to 10 in the generated yaml

```
---
apiVersion: v1
kind: Service
metadata:
  name: example-myapp
  labels:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: example
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: example
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: example-myapp
  labels:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: example
spec:
  replicas: 10
  selector:
    matchLabels:
      app.kubernetes.io/name: myapp
      app.kubernetes.io/instance: example
  template:
    metadata:
      labels:
        app.kubernetes.io/name: myapp
        app.kubernetes.io/instance: example
    spec:
      containers:
        - name: myappcontainer
          image: "nginx:latest"
          ports:
            - name: http
              containerPort: 80
              protocol: TCP

---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-myapp
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: "/"
spec:
  rules:
  - host: www.myapp.com
    http:
      paths:
      - backend:
          serviceName: example-myapp
          servicePort: 80
        path: /

```

So we can now scale up to ten instances using

```
helm template --name=example --set-string replicas=10 .  | kubectl apply -f -
```

Check the running pods to confirm there are in fact ten instances
```
kubectl get pods
```

```
NAME                             READY   STATUS    RESTARTS   AGE
example-myapp-768cd7d675-2vwxg   1/1     Running   0          3m37s
example-myapp-768cd7d675-8gwnn   1/1     Running   0          3m37s
example-myapp-768cd7d675-9fvgd   1/1     Running   0          3m37s
example-myapp-768cd7d675-fj2nw   1/1     Running   0          3m37s
example-myapp-768cd7d675-pfgmv   1/1     Running   0          3m37s
example-myapp-768cd7d675-qpvfz   1/1     Running   0          3m37s
example-myapp-768cd7d675-qw4lj   1/1     Running   0          3m37s
example-myapp-768cd7d675-rcjjp   1/1     Running   0          3m37s
example-myapp-768cd7d675-tvvwq   1/1     Running   0          3m37s
example-myapp-768cd7d675-zsdm7   1/1     Running   0          3m37s

```

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
