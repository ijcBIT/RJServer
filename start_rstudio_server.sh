#!/bin/bash

export SLUMR_SERVER_NAME="RStudio Server"
export SLUMR_SERVER_SCRIPT="./bin/rstudio_server.slm"
export SLUMR_SERVER_CONTAINER_NAME="tidyverse_4.4.1.sif"
export SLUMR_SERVER_DEFAULT_CONTAINER_LIB="merkel/tidyverse:4.4.1"
export SLUMR_SERVER_LOG_FOLDER="rstudio_server"
export LOCAL_PORT="8787"

# Submit job using sbatch
./bin/start_in_cluster.sh "$@" 2>&1
