#!/bin/bash -x

NET_NO=${1:-100}
CONT_NAME=net$NET_NO
CARRIER_NIC=${2:-eth0}
# IMAGE=debian
IMAGE=nicolaka/netshoot

docker run \
    --rm -d \
    --network none \
    --name ${CONT_NAME} \
    --hostname ${CONT_NAME} \
    $IMAGE sleep infinity

# make sure the container is running
until [ "x`docker inspect -f {{.State.Running}} ${CONT_NAME} || true`" == "xtrue" ]; do
    echo "wait for container/state.running"
    sleep 0.1
done
# wait for pid
until [ "x`docker inspect -f {{.State.Pid}} ${CONT_NAME} || true`" != "x" ]; do
    echo "wait for container/state.pid"
    sleep 0.1
done

# modprobe --first-time 8021q

# create namespace link
[ -d /var/run/netns ] || mkdir -p /var/run/netns
DPID=$(docker inspect --format '{{ .State.Pid }}' "${CONT_NAME}")
ln -sfT "/proc/$DPID/ns/net" "/var/run/netns/${CONT_NAME}"

ip link set ${CARRIER_NIC}.${NET_NO} down
ip link del ${CARRIER_NIC}.${NET_NO}
ip link add link ${CARRIER_NIC} name ${CARRIER_NIC}.${NET_NO} type vlan id ${NET_NO}
ip link set netns ${CONT_NAME} dev ${CARRIER_NIC}.${NET_NO}
