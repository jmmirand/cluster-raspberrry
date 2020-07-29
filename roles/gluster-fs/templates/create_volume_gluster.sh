#!/usr/bin/env bash
{% for server in groups['raspberrycluster']%}
    CLUSTER_SERVER=" $CLUSTER_SERVER {{server}}:/data/glusterfs/myvol1/brick1/brick"
{% endfor %}


gluster volume create myvol1 replica 4 $CLUSTER_SERVER
sudo gluster volume start myvol1
