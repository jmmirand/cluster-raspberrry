# cluster-raspberrry


Queremos montar un cluster kubernetes con varias Raspberry Pi 4 Modelo B. 

Además aprovecharemos para automatizarlo con Ansible lo más posible para poder recrear el cluster tantas veces que sea necesario.

Nuestro cluster kubernetes estará compuestos por 4 Raspberry PI.
 * 1 master
 * 3 workers
Usaremos para hacerlo el sistema operativo Ubuntu Server de 64 bits.

## Instalación y preparación del Sistema Operativo

Para el laborario usamos [ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz](https://ubuntu.com/download/raspberry-pi/thank-you?version=20.04&architecture=arm64+raspi) como S.O.

Una vez descargado lo instalo con **raspberry Pi Imager**.

Es muy sencillo, inserto la SDCard , eligo la imagen y la escribo.

Insertamos la SDCard en la Raspberry Pi y Arrancamos.

La ip asiganda para acceder a ella lo hacemos con el comando nmap

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

Y comprobamos que conectamos correctamente usuario/password por defecto son **(ubuntu/ubuntu)**

```
➜  ~ ssh ubuntu@192.168.1.61
ubuntu@192.168.1.61's password:
Welcome to Ubuntu 20.04 LTS (GNU/Linux 5.4.0-1008-raspi aarch64)
..

ubuntu@ubuntu:~$
```



### Prepareación previa de las servidores.


###  Asignar IP Fija

Para facilitar la insalación hay que asignar IPs fijas a las máquinas y poner nombre a las máquinas.

Lo primero que tenemos que hacer es revisar en el rooter cual es el rango de IPs que asigna el DHCP.

En mi caso el rango es [192.168.1.33 - 192.168.1.199] , con lo cual las que escoja para asignar fija debemos coger fuera de este rango.

Master : 192.168.1.10
Worker-01: 192.168.1.11
Worker-02: 192.168.1.12
Worker-03: 192.168.1.13

Como el sistema operativo que estamos usando es **Ubuntu-Server**  la asignación de la ip fija es modificando el fichero.

 * Para la asignación vamos a utilizar ips fuera del rango de IPs que proprociona el servidor de DHCP del Rotuer
 * Necsitamos saber los datos del servidor DNS que tenemos configurado en la máuqina


/etc/netplan/50-cloud-init.yaml

```
network:
    ethernets:
        eth0:
            dhcp4: false
            optional: true
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



**Ref** : [Raspberry Pi static IP & DHCP Server Ubuntu 18.04](https://askubuntu.com/questions/1218755/raspberry-pi-static-ip-dhcp-server-ubuntu-18-04)
