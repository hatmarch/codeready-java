#!/bin/bash

minishift profile set cicd
minishift --profile cicd config set memory 10240
minishift --profile cicd config set cpus 3 # (1)
minishift --profile cicd config set vm-driver virtualbox #hyperkit (2)
minishift addon enable admin-user #(4)
# minishift addon enable anyuid # (5)
minishift addon enable xpaas
minishift start --profile cicd #(6)