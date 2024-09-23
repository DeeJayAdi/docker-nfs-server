# NFS Server Docker Image

This Docker image runs an NFS server, allowing you to share directories over the network.

## Setting Shared Directories through ENV

Shared directories are set through environment variables only.

Example ENV:

```
SHARED_DIRECTORY=/export
SHARED_DIRECTORY_1=/path1
SHARED_DIRECTORY_...=/path...
```

## Pull image

```
docker pull deejayadi/nfs-server:latest
```

## Run Container

To run the container with the specified environment variables, use the following command:

```
docker run -d --name nfs-server -e SHARED_DIRECTORY=/export -e SHARED_DIRECTORY_1=/path1 deejayadi/nfs-server:latest
```

## Port numbers

- 111 - rpcbind
- 2049 - nfs
- 20048 - mountd

## Example kubernetes deployment

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nfs
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nfs-server
  name: nfs-server
  namespace: nfs
spec:
  selector:
    matchLabels:
      app: nfs-server
  template:
    metadata:
      labels:
        app: nfs-server
    spec:
      nodeSelector:
        storage: "true"
      containers:
        - image: deejayadi/nfs-server:latest
          imagePullPolicy: IfNotPresent
          name: nfs-server
          resources: {}
          securityContext:
            privileged: true
            capabilities:
              add:
                - SYS_ADMIN
                - NET_ADMIN
                - SETPCAP
          env:
            - name: SHARED_DIRECTORY
              value: /disk
          ports:
            - containerPort: 111
              name: rpcbind
            - containerPort: 2049
              name: nfs
            - containerPort: 20048
              name: motund
          volumeMounts:
            - mountPath: /disk
              name: disk
      volumes:
        - name: disk
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nfs-server
  name: nfs-server
  namespace: nfs
spec:
  selector:
    app: nfs-server
  clusterIP: None
  ports:
    - name: rpcbind
      port: 111
      protocol: TCP
      targetPort: 111
    - name: nfs
      port: 2049
      protocol: TCP
      targetPort: 2049
    - name: mountd
      port: 20048
      protocol: TCP
      targetPort: 20048
```
