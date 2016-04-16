#!/bin/bash

scp -i ~/.ssh/udacity_key.rsa ./setup_server.bash root@52.26.115.20:
ssh -i ~/.ssh/udacity_key.rsa root@52.26.115.20 bash '~/setup_server.bash'

