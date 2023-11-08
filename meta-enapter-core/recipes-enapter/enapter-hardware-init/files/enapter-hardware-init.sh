#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# HW_EMUCB202_INIT=1 HW_COM0_DEVICE=/dev/ttyS0 HW_COM1_DEVICE=/dev/ttyS1 /usr/bin/enapter-hardware-init

wait_for_device() {
  local timeout=5
  local device="$1"

  while [ "$timeout" -gt 0 ] && [ ! -e "$device" ]; do
    echo "Waiting device $device"
    timeout=$((timeout-1))
    sleep 1
  done

  if [ ! -e "$device" ]; then
    echo "timed out waiting ${device}" 1>&2
    return 1
  fi
}

wait_for_network_device() {
  local timeout=5
  local device="$1"

  while [ "$timeout" -gt 0 ] && [ ! -e "/sys/class/net/$device/operstate" ]; do
    echo "Waiting device $device"
    timeout=$((timeout-1))
    sleep 1
  done

  if [ ! -e "/sys/class/net/$device/operstate" ]; then
    echo "timed out waiting ${device}" 1>&2
    return 1
  fi
}

if [[ -n "${HW_EMUCB202_INIT}" ]]; then
  echo "Init EMUCB202..."
  socket_name_1=${HW_EMUCB202_INTERFACE1_NAME:-can0}
  socket_name_2=${HW_EMUCB202_INTERFACE1_NAME:-can1}

  dev_name=${HW_EMUCB202_DEVICE_NAME:-ttyACM0}

  baudrate=${HW_EMUCB202_BAUD_RATE:-7}    # 4: 100 KBPS, 5: 125 KBPS,  6: 250 KBPS, 7: 500 KBPS,
                                          # 8: 800 KBPS, 9: 1 MBPS,   10: 400 KBPS
  error_type=${HW_EMUCB202_ERROR_TYPE:-0} # 0: EMUC_DIS_ALL, 1: EMUC_EE_ERR, 2: EMUC_BUS_ERR, 3: EMUC_EN_ALL

  # load required kernel module
  modprobe emuc2socketcan

  # run service which is responsible for creating proper network devices (can0, can1)
  emucd -s${baudrate} -e${error_type} ${dev_name} ${socket_name_1} ${socket_name_2}

  wait_for_network_device can0
  wait_for_network_device can1

  ip link set ${socket_name_1} txqueuelen 1000
  ip link set ${socket_name_2} txqueuelen 1000
  tc qdisc add dev ${socket_name_1} root handle 1: pfifo
  tc qdisc add dev ${socket_name_2} root handle 1: pfifo
  ip link set ${socket_name_1} up
  ip link set ${socket_name_2} up
fi


mkdir -p /dev/com/

if [[ -n "${HW_COM0_DEVICE}" ]]; then
  echo "Init com0..."
  wait_for_device "${HW_COM0_DEVICE}" && ln -s -f ${HW_COM0_DEVICE} /dev/com/com0
fi

if [[ -n "${HW_COM1_DEVICE}" ]]; then
  echo "Init com1..."
  wait_for_device "${HW_COM1_DEVICE}" && ln -s -f ${HW_COM1_DEVICE} /dev/com/com1
fi

if [[ -n "${HW_COM2_DEVICE}" ]]; then
  echo "Init com2..."
  wait_for_device "${HW_COM2_DEVICE}" && ln -s -f ${HW_COM2_DEVICE} /dev/com/com2
fi

if [[ -n "${HW_COM3_DEVICE}" ]]; then
  echo "Init com3..."
  wait_for_device "${HW_COM3_DEVICE}" && ln -s -f ${HW_COM3_DEVICE} /dev/com/com3
fi
