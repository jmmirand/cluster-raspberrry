# cluster-raspberrry

Ref [Laboratorio Cluster Kubernete Jeff-Geerling](https://www.youtube.com/watch?v=kgVz4-SEhbE&list=PL2_OBreMn7Frk57NLmLheAaSSpJLLL90G)

Queremos montar un cluster kubernetes con varias Raspberry Pi 4 Modelo B.

Además aprovecharemos para automatizarlo con Ansible lo más posible para poder recrear el cluster tantas veces que sea necesario.

Nuestro cluster kubernetes estará compuestos por 4 Raspberry PI.
 * 1 master
 * 3 workers
Usaremos para hacerlo el sistema operativo Ubuntu Server de 64 bits.

## Instalación y preparación del Sistema Operativo

Para el laborario usamos [ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz](https://ubuntu.com/download/raspberry-pi/thank-you?version=20.04&architecture=arm64+raspi) como S.O.

Para la instalación del S.O.:

* Descargamos e instalamos **raspberry Pi Imager**.
* Si estamos reutilizando la tarjeta hay que borrarla con el programa de **"Utilidades de Disco"**
* Isertamos SDCard , eligimos la imagen y escribimos.
* Insertamos la SDCard en la Raspberry Pi y Arrancamos.
* Averiguamos La ip asiganda a la Rasberry con el comando *nmap* y necesito como dato la subred.

``` bash
➜  ~ nmap -sn 192.168.1.0/24
Starting Nmap 7.80 ( https://nmap.org ) at 2020-07-11 08:00 CEST
Nmap scan report for 192.168.1.1
Host is up (0.0055s latency).
Nmap scan report for 192.168.1.2
Host is up (0.011s latency).
Nmap scan report for 192.168.1.35
Host is up (0.0060s latency).
Nmap scan report for 192.168.1.61
Host is up (0.00038s latency).
Nmap done: 256 IP addresses (6 hosts up) scanned in 7.89 seconds
```

* Comprobamos que conectamos correctamente usuario/password por defecto son **(ubuntu/ubuntu)**
* La primera vez que conectemos, nos pedirá que cambiemos la password.
* **Si re-instalamos hay que actualizar el fichero knowed-host de .ssh elminando las IPs repetidas*

```
➜  ~ ssh ubuntu@192.168.1.61
ubuntu@192.168.1.61's password:
Welcome to Ubuntu 20.04 LTS (GNU/Linux 5.4.0-1008-raspi aarch64)
..

ubuntu@ubuntu:~$
```


### Prepareación previa de las servidores.

## Preparación previa de las servidores.

Para facilitar la instalación hay que asignar IPs fijas a las máquinas y poner nombre a las máquinas.

###  Asignar IP Fija


Lo primero que tenemos que hacer es revisar en el rooter cual es el rango de IPs que asigna el DHCP.

En mi caso el rango es [192.168.1.33 - 192.168.1.199] , con lo cual las que escoja para asignar fija debemos coger fuera de este rango.

Master : 192.168.1.10
Worker-01: 192.168.1.11
Worker-02: 192.168.1.12
Worker-03: 192.168.1.13

Como el sistema operativo que estamos usando es **Ubuntu-Server 20.04LTS**  la asignación de la ip fija es modificando el fichero.

 * Para la asignación vamos a utilizar ips fuera del rango de IPs que proporciona el servidor de DHCP del Router
 * Necesitamos saber los datos del servidor DNS que tenemos configurado en la máquina

A partir de la versión 18.04 LTS se cambia la forma de configurar los interfaces de red y en vez de modificar el fichero /etc/network/interfaces usaremos **netplan**.

 * Ref [How to configure networking with Netplan on Ubuntu](https://vitux.com/how-to-configure-networking-with-netplan-on-ubuntu/)
 * Ref : [Raspberry Pi static IP & DHCP Server Ubuntu 18.04](https://askubuntu.com/questions/1218755/raspberry-pi-static-ip-dhcp-server-ubuntu-18-04)

/etc/netplan/50-cloud-init.yaml

```
network:
    ethernets:
        eth0:
            dhcp4: false
            optional: true
            gateway4: 192.168.1.1
            addresses:
              - 192.168.1.10/24
            nameservers:
              addresses: [8.8.8.8,4.4.4.4]

    version: 2

```
### Asignación nombre de máquinas


Para la asignación de nombres de máquinas modificamos

/etc/hostanme

donde viene **ubuntu** por el nuevo nombre , en nuestro caso una con  **master** y las otras tres como **worker01**,**workder02**, etc..

reiniciamo el servidor

```
ubuntu@master:~$ sudo reboot

```

### Configurar claves SSH

Necsitamos tener una pareja de clave publica/privada

En la máquina añadimos dicha clave en el fichero **${HOME}.ssh/authorized_keys**


### Automatizado con Ansible

El playbook parte de la máquina con la password actualizada:
 * asigna nombre máquina
 * cambia a una ip fija
 * actuailza la clave pública.

```
ansible-playbook playbooks/prepare_servers.yml  \
  -i inventories -k -K --ask-vault-pass \
  -u ubuntu \
  --limit 192.168.1.64
```

Si se quiere lanzar una vez cambiadas las IPs

```
ansible-playbook playbooks/prepare_servers.yml  \
  -i inventories  \
  --ask-vault-pass \
  -u ubuntu \
  -e launchHosts=raspberrycluster
```

# Instalación y Comprobación cluster kubernetes

## Preparación Ansible

Usaremos la implementación k3s de kubernetes

Para la instalación usamos el playbook [k3-ansible](https://github.com/rancher/k3s-ansible)

Descargamos y creamos un inventario nuevo my-cluster

```
├── inventory
│   ├── my-cluster
│   │   ├── group_vars
│   │   │   └── all
│   │   │       └── vars.yml
│   │   └── hosts
```

En el hosts añadimos los servidores recion instalados.

``` ini
[master]
192.168.1.10

[node]
192.168.1.[11:13]


[k3s_cluster:children]
master
node
```

Y actualizamos las variables , cambiando user_ansible.

``` yaml
---
k3s_version: v1.17.5+k3s1
ansible_user: ubuntu
systemd_dir: /etc/systemd/system
master_ip: "{{ hostvars[groups['master'][0]]['ansible_host'] | default(groups['master'][0]) }}"
extra_server_args: ""
```

## Instalación cluster kubernetes

Ejecutamos el playbooks

``` bash
➜  k3s-ansible git:(master) ansible-playbook site.yml -i inventory/my-cluster -u ubuntu
```

## Comprobación cluster

Una vez instalado comprobamos que está bien levantado.
 * compiamos el fichero configuración de kubernete del master
 * Atualizamos la variable de Kuberentes
 * Comprobamos la versión servidor
 * Comando de comprobación


``` bash
➜  k3s-ansible git:(master) scp ubuntu@192.168.1.10:~/.kube/config ~/.kube/config-pi
➜  k3s-ansible git:(master) export KUBECONFIG=~/.kube/config
➜  k3s-ansible git:(master) kubectl version
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.3", GitCommit:"b3cbbae08ec52a7fc73d334838e18d17e8512749", GitTreeState:"clean", BuildDate:"2019-11-14T04:24:34Z", GoVersion:"go1.12.13", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.5+k3s1", GitCommit:"58ebdb2a2ec5318ca40649eb7bd31679cb679f71", GitTreeState:"clean", BuildDate:"2020-05-06T23:42:07Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/arm64"}

➜  k3s-ansible git:(master) kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
worker02   Ready    <none>   33m   v1.17.5+k3s1
worker03   Ready    <none>   33m   v1.17.5+k3s1
worker01   Ready    <none>   33m   v1.17.5+k3s1
master     Ready    master   33m   v1.17.5+k3s1

```

## Parar el Cluster

``` bash
➜  k3s-ansible git:(master) ansible all -i inventory/my-cluster  -a "shutdown now"  -b -u ubuntu
```



# Instalación Aplicaciones


## Cluster-monitoring


 * Intentamos con  [kube-prometheus](https://github.com/coreos/kube-prometheus) pero da error en Rasberry

 * Instalamos la monitorización con el proyecto [cluster-monitoring](https://github.com/carlosedp/cluster-monitoring)
   - Seguimos las instrucciones  del QuicStart


## Instalación de glusterFS

 * Para la instalación del cluster dejamos preparado un disco que lo dejaremos dedicado a glusterFs.





Instalación de GlusterFS

https://www.gopeedesignstudio.com/2018/07/13/glusterfs-on-arm/

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



https://mattcurfman.com/index.php/2019/03/25/k38s-on-a-4-node-up-board-cluster/
https://computingforgeeks.com/configure-kubernetes-dynamic-volume-provisioning-with-heketi-glusterfs/
https://www.jorgedelacruz.es/2018/08/23/kubernetes-helm-heketi-con-glusterfs/






Documentación Oficial: https://docs.gluster.org/en/latest/Administrator%20Guide/Managing%20Volumes/
Instalción Heteki: Como funciona https://www.youtube.com/watch?v=uaNZx2O9ihc
Video Explicativo como  funciona Kubernete + Gluster FS + Heketi : https://www.youtube.com/watch?v=xml6RGbWHsI
Ejemplo Openshift : https://docs.openshift.com/container-platform/3.4/install_config/storage_examples/gluster_dynamic_example.html

Instalación Heketi: https://github.com/heketi/heketi/blob/6baf9866d95906dd03b88621150e312dcccdb33f/docs/design/kubernetes-integration.md



[QuickStart Gluster FS](https://www.gopeedesignstudio.com/2018/07/13/glusterfs-on-arm/)


PTe revisar https://www.youtube.com/watch?v=IGEtVYh0C2o&list=PL34sAs7_26wOwCvth-EjdgGsHpTwbulWq



https://medium.com/searce/glusterfs-dynamic-provisioning-using-heketi-as-external-storage-with-gke-bd9af17434e5
