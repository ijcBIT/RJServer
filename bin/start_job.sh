#!/bin/bash

# Create temporary directory to be populated with directories to bind-mount in the container
# where writable file systems are necessary. 
workdir="${PWD}/${SLUMR_SERVER_LOG_FOLDER}"
mkdir -p -m 700 $workdir

# Load singularitty module from cluster LMOD 
module load singularity

# pull default image from the library if not present
if  [ "$SLUMR_SERVER_CONTAINER_NAME" == "$CONTAINER_NAME" ] && [ ! -e "$CONTAINER_NAME" ]; then
    singularity pull --library http://10.110.20.108 library://$SLUMR_SERVER_DEFAULT_CONTAINER_LIB
fi

# Submit job using sbatch
JOB_ID=$(sbatch --parsable $SLURM_SBATCH_OPTIONS $SLUMR_SERVER_SCRIPT "$CONTAINER_NAME")

## Wait until the job has started
while true; do
    # Get the job state
    JOB_STATE=$(squeue -j $JOB_ID -h -o '%T')

    if [[ "$JOB_STATE" == "RUNNING" ]]; then
        break  # Exit the loop
    fi

    sleep 1  # Wait before rechecking
done

# Print the slurm job id to cancel it when finished
echo "$JOB_ID"

