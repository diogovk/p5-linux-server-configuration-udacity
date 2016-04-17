#!/bin/bash

SSH_PORT=2200

set -e
scp -P $SSH_PORT -i ~/.ssh/udacity_key.rsa ./setup_server.bash root@52.26.115.20:
ssh -p $SSH_PORT -i ~/.ssh/udacity_key.rsa root@52.26.115.20 bash '~/setup_server.bash'

