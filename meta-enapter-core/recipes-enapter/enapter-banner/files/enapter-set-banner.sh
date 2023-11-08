#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0
warning_message="
Welcome to Enapter Gateway!

Please access the Gateway web interface:
- Use \"http://enapter-gateway.local\" from a browser on your computer
  or mobile device connected to the same network as the Gateway.
- If the link above does not work, access the Gateway using IP address.
  To find out your IP address, type \"ip\" command into the command line below
  and press <Enter>.
  Then type the IP address into your browser address bar and press <Enter>.
"

echo -e "$warning_message" >>/etc/issue
