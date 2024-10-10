#!/bin/bash

export SLUMR_SERVER_NAME="Jupyter Notebook"
export SLUMR_SERVER_SCRIPT="./bin/jupyter_notebook.slm"
export SLUMR_SERVER_CONTAINER_NAME="jupyter_20240701.sif"
export SLUMR_SERVER_DEFAULT_CONTAINER_LIB="merkel/jupyter:20240701"
export SLUMR_SERVER_LOG_FOLDER="jupyter_notebook"
export LOCAL_PORT="8888"

# Submit job using sbatch
./bin/start_in_cluster.sh "$@" 2>&1
