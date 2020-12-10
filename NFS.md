# NFS en raspberry

Basado en el articulo [Setting up an raspberrypi4 k3s-cluster with nfs persistent-storage](https://medium.com/@michael.tissen/setting-up-an-raspberrypi4-k3s-cluster-with-nfs-persistent-storage-a931ebb85737)

Se configura el cluster k3s con un servicio de Storage Persistente Basado en ClusterFS.

# Instalación NFS ( server/client)

En el cluster que tenemos montamos un servicio de NFS para laboratorio donde el master
es el servidor y exportamos el directorio /mnt/nfs y los workers hacen de cliente montando el
FS /mnt/nfs



# Instalación nfs-client provisioner

Descargamos los manifiestos yaml y configuramos deployment con los datos de nuestro NFS

  * [rbac.yaml](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/raw/master/deploy/rbac.yaml)
  * [class.yaml](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/raw/master/deploy/class.yaml)
  * [deployment.yaml](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/blob/master/deploy/deployment-arm.yaml)


Adaptamos el yaml con los datos del servidor NFS

``` yaml
# ./NFS/deployment-arm.yaml
serviceAccountName: nfs-client-provisioner
containers:
  - name: nfs-client-provisioner
    image: quay.io/external_storage/nfs-client-provisioner-arm:latest
    volumeMounts:
      - name: nfs-client-root
        mountPath: /persistentvolumes
    env:
      - name: PROVISIONER_NAME
        value: fuseim.pri/ifs
      - name: NFS_SERVER
        value: 192.168.1.10
      - name: NFS_PATH
        value: /mnt/nfs
volumes:
  - name: nfs-client-root
    nfs:
      server: 192.168.1.10
      path: /mnt/nfs
```


Ejecutamos el script

``` bash
sudo kubectl create -f rbac.yaml
sudo kubectl create -f deployment-arm.yaml
sudo kubectl create -f class.yaml
```


## Uso nuevo NFS-Provisioner

Con la creación de este volumen

``` yaml
# ./NFS/test-volumen.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ghost-pv-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
  labels:
    app: blog
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```
Aplicar este volumen

``` bash
➜ ✗ kubectl create -f test-volume.yaml
persistentvolumeclaim/ghost-pv-claim created

➜ ✗ kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
ghost-pv-claim   Bound    pvc-14a91e31-b57d-4c33-8937-b71e55f782de   5Gi        RWX            managed-nfs-storage   2m40s
➜  NFS git:(master) ✗

```



Se puede validar en el propio nodo del cluster

``` bash
ubuntu@master:/mnt/nfs$ ll
total 16
drwxrwxrwt 3 root   root   4096 Dec 10 08:02 ./
drwxr-xr-x 3 root   root   4096 Dec  8 22:25 ../
drwxrwxrwx 2 ubuntu ubuntu 4096 Dec 10 08:02 default-ghost-pv-claim-pvc-14a91e31-b57d-4c33-8937-b71e55f782de/
ubuntu@master:/mnt/nfs$
```
