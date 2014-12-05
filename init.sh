#!/bin/bash

fcgiwrap -s unix:/var/run/fcgiwrap.socket &
nginx -g 'daemon off;'
