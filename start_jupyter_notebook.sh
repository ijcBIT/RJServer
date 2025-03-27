#!/bin/bash

export SLURM_SERVER_NAME="Jupyter Notebook"
export SLURM_SERVER_SCRIPT="./bin/jupyter_notebook.slm"
export SLURM_SERVER_CONTAINER_NAME="jupyter_20240701.sif"
export SLURM_SERVER_DEFAULT_CONTAINER_LIB="merkel/jupyter:20240701"
export SLURM_SERVER_LOG_FOLDER="jupyter_notebook"
export LOCAL_PORT="8888"

# Submit job using sbatch
./bin/start_in_cluster.sh "$@" 2>&1
