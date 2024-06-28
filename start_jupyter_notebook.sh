#!/bin/bash

export SLUMR_SERVER_NAME="Jupyter Notebook"
export SLUMR_SERVER_SCRIPT="./bin/jupyter_notebook.slm"
export SLUMR_SERVER_CONTAINER_NAME="datascience-notebook_2024-06-24.sif"
export SLUMR_SERVER_LOG_FOLDER="jupyter_notebook"

# Submit job using sbatch
./bin/start.sh 2>&1
