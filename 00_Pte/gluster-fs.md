# Instalación GlusterFs en Rasberry

No tuvo existo la instalación, por problemas varios.


## Instalación de glusterFS

Instalación de GlusterFS

Aplicaremos este articulo:
https://piensoluegoinstalo.com/despliegue-de-aplicaciones-con-helm-heketi-cli-glusterfs/

Interesate También le costó mucho y comenta que nos lo explica.
https://blog.lwolf.org/post/how-i-deployed-glusterfs-cluster-to-kubernetes/




Para la integración de kubernetes necesitamos instalar heketi.
Seguimos la instalación https://github.com/heketi/heketi/blob/master/docs/design/kubernetes-integration.md d

Cuando creamos el ddemonset da error,  para resolverlo:

Rehacer la imagen de gluster-centos para rasberry pi.
https://hub.docker.com/r/gluster/gluster-centos/dockerfile
Para ello vamos al repositorio github https://github.com/gluster/gluster-containers
Dockerfile https://github.com/gluster/gluster-containers/tree/master/CentOS y lo guardo en
jmmirand/gulster-cento.fs

kubectl label node  worker01 worker02 worker03 storagenode=glusterfs

heketi/heketi:dev : Mp está compilada para ARM hay que compilarla.

https://hub.docker.com/r/heketi/heketi
https://github.com/heketi/heketi


Para la construcción de la imagen tenemos que tener instalado el entorno
sudo apt-get install make
sudo apt-get install golang-glide
sudo apt-get install golang-go
sudo apt-get install mercurial

y ahora hay que configurar el entorno de Go


https://docs.okd.io/3.7/install_config/storage_examples/containerized_heketi_with_dedicated_gluster.html









Documentación Oficial: https://docs.gluster.org/en/latest/Administrator%20Guide/Managing%20Volumes/
Instalción Heteki: Como funciona https://www.youtube.com/watch?v=uaNZx2O9ihc
Video Explicativo como  funciona Kubernete + Gluster FS + Heketi : https://www.youtube.com/watch?v=xml6RGbWHsI
Ejemplo Openshift : https://docs.openshift.com/container-platform/3.4/install_config/storage_examples/gluster_dynamic_example.html

Instalación Heketi: https://github.com/heketi/heketi/blob/6baf9866d95906dd03b88621150e312dcccdb33f/docs/design/kubernetes-integration.md



[QuickStart Gluster FS](https://www.gopeedesignstudio.com/2018/07/13/glusterfs-on-arm/)


PTe revisar https://www.youtube.com/watch?v=IGEtVYh0C2o&list=PL34sAs7_26wOwCvth-EjdgGsHpTwbulWq



https://medium.com/searce/glusterfs-dynamic-provisioning-using-heketi-as-external-storage-with-gke-bd9af17434e5
