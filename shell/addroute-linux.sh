#!/bin/bash
route add -net 10.100.100.0/24 gw 10.0.1.87
route add -net 192.168.0.0/16 gw 10.0.1.87
