#!/usr/bin/env bash

container_name=UVMS
ROOTDIR=${ROOTDIR:-/opt/univiewer_server}
UV_NODE=${UV_NODE:-docker_uvms_MgtServer}

#En v7: 
echo "[${container_name}] Starting Univiewer Server ${UV_NODE}..."
${ROOTDIR}/${UV_NODE}/app/bin/unistartms
#En v6 (commenter la ligne ci-dessus et décommenter celle ci-dessous):
#${ROOTDIR}/${UV_NODE}/app/bin/unistart

echo "[${container_name}] Container running..."
# The following command makes the script blocking. Otherwise the container ends directly after uvms start...
tail -f /dev/null

echo "[${container_name}] Container stopping..."