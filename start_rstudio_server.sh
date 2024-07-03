#!/bin/bash

export SLUMR_SERVER_NAME="RStudio Server"
export SLUMR_SERVER_SCRIPT="./bin/rstudio_server.slm"
export SLUMR_SERVER_CONTAINER_NAME="tidyverse_4.4.1.sif"
export SLUMR_SERVER_DEFAULT_CONTAINER_LIB="merkel/tidiverse:4.4.1"
export SLUMR_SERVER_LOG_FOLDER="rstudio_server"


# Submit job using sbatch
./bin/start.sh "$@" 2>&1
