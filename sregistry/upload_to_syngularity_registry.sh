#!/bin/bash

singularity build bioconductor_tidyverse_3_20-R-4.4.2.sif  docker://bioconductor/tidyverse:RELEASE_3_20-R-4.4.2
singularity remote add --insecure --no-login ijc 10.110.20.108
singularity remote login ijc
singularity remote use ijc
# library://user/collection/container[:tag]
singularity push --no-https -U bioconductor_tidyverse_3_20-R-4.4.2 library://elario/merkel/tidyverse:3_20-R-4.4.2