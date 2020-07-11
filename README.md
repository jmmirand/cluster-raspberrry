# cluster-raspberrry


# Objetivo

Documenter todos los pasos realizados para montar un cluster con 4 raspberry Pi.

Una vez montado el hardware instalaremos ubuntu server 64bit.

En los servidores instalaremos un cluster kubernetes con 1 master y 3 workers.


# Instalación y preparación del Sistema Operativo

Descargamos la imagen del Sistema Operativo. En este laborario usamos Ubuntu Server 64bits

La imagen se llama [ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz](https://ubuntu.com/download/raspberry-pi/thank-you?version=20.04&architecture=arm64+raspi)



El sistema operativo lo podemos instalar con el software **raspberry Pi Imager**

 * Elegimos SD Card
 * Elegimos Fichero imagen que nos hemos descargado previamente
 * Escribimos la imagen

 Una vez terminado la insertamos en la Raspberry Pi y Arrancamos.

Para acceder a ella averiguamos la ip

```
Starting Nmap 7.80 ( https://nmap.org ) at 2020-07-11 08:00 CEST
Nmap scan report for 192.168.1.1
Host is up (0.0055s latency).
Nmap scan report for 192.168.1.2
Host is up (0.011s latency).
Nmap scan report for 192.168.1.35
Host is up (0.0060s latency).
Nmap scan report for 192.168.1.44
Host is up (0.00038s latency).
Nmap done: 256 IP addresses (6 hosts up) scanned in 7.89 seconds
```
Y comprobamos que conectamos correctamente usuario/password por defecto son **(ubuntu/ubuntu)**



## Prepareación previa de las servidores.

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


### Asignación nombre de máquinas


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










Ref : [Raspberry Pi static IP & DHCP Server Ubuntu 18.04](https://askubuntu.com/questions/1218755/raspberry-pi-static-ip-dhcp-server-ubuntu-18-04)
