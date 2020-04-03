#!/bin/bash

iptables -I INPUT -s a.b.c.d -j DROP
# the above is duplicated as necessary
