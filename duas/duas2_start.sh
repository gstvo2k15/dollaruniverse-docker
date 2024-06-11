#!/usr/bin/env bash

# Initialization
container_name="DUAS2"
ROOTDIR=/opt/DUAS

UV_HOST=${UV_HOST:-uvms}
UV_PORT=${UV_PORT:-4184}
UV_LOGIN=${UV_LOGIN:-admin}
UV_PWD=${UV_PWD:-admin}

DU_COMPANY=${DU_COMPANY:-UNI700}
DU_NODE=${DU_NODE:-docker_node2}
DU_HOST=${DU_HOST:-duas2}
DU_IOPORT=${DU_IOPORT:-10700}

echo "[${container_name}] Waiting for uvms to be available on ${UV_HOST}:${UV_PORT}..."
wait-for-it.sh ${UV_HOST}:${UV_PORT} -t 0

cd ${ROOTDIR}
. ./unienv.ksh

if [ "${DU_COMPANY}" != "${COMPANY_NAME}" ] || [ "${DU_NODE}" != "${S_NODENAME}" ]; then
   
  # Stop the DUAS Company  
  cd ${ROOTDIR}/bin
  ./unistop
  
  echo "[${container_name}] unirefactorinst command is RUNNING ([${S_ID_COMPANY}/${S_NODENAME}] changing to [${DU_COMPANY}/${DU_NODE}]@${DU_HOST}:${DU_IOPORT})....."
  ./unirefactorinst -mslogin ${UV_LOGIN} -mspwd ${UV_PWD} -msport ${UV_PORT} -mshost $UV_HOST -company ${DU_COMPANY} -node ${DU_NODE} -host ${DU_HOST} -port ${DU_IOPORT} 2>/tmp/unirefactorinst.log
  if [ $? -ne 0 ]; then 
    RC=$? 
    echo "[${container_name}] unirefactorinst has FAILED...."
    exit $RC
  else
    echo "[${container_name}] unirefactorinst command is in SUCCESS ....."
    cd ${ROOTDIR}
    . ./unienv.ksh   
  fi  
fi

cd ${ROOTDIR}/bin
./unims -checkms

if [ $? -ne 0 ]; then
        echo "[${container_name}] Registering to UVMS ..."
	sleep 10
        ./unims -register -mshost $UV_HOST -msport ${UV_PORT} -login ${UV_LOGIN} -pwd ${UV_PWD} -host ${DU_HOST} 2>/tmp/unims.log
	sleep 10
        if [ $? -ne 0 ]; then
          echo "[${container_name}] Registering failed"
          grep -q "already exists" /tmp/unims.log
          if [ $? -eq 0 ]; then
            echo "[${container_name}] Node already registered to uvms $UV_HOST - updating passphrase..."
            ./unims -update -passphrase
            if [ $? -ne 0 ]; then
              echo "[${container_name}] Register update failed"
              ping -c 1 $UV_HOST
              nc -v -z $UV_HOST ${UV_PORT}
              exit $?
            fi
          else
            ping -c 1 $UV_HOST
            nc -v -z $UV_HOST ${UV_PORT}
            exit $?
          fi
        fi
fi

echo "[${container_name}] Starting duas..."
./unistart

echo "[${container_name}] Started - container running..."
tail -f /dev/null

echo "[${container_name}] Stopping..."
