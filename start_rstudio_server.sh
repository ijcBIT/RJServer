#!/bin/bash

export SLURM_SERVER_NAME="RStudio Server"
export SLURM_SERVER_SCRIPT="./bin/rstudio_server.slm"
export SLURM_SERVER_CONTAINER_NAME="bioconductor_tidyverse_3_20-R-4.4.2.sif"
export SLURM_SERVER_DEFAULT_CONTAINER_LIB="merkel/tidyverse_3_20:4.4.2"
export SLURM_SERVER_LOG_FOLDER="rstudio_server"
export LOCAL_PORT="8787"

# Submit job using sbatch
./bin/start_in_cluster.sh "$@" 2>&1
