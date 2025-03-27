#!/bin/bash

# Create temporary directory to be populated with directories to bind-mount in the container
# where writable file systems are necessary. 
workdir="${PWD}/${SLURM_SERVER_LOG_FOLDER}"
mkdir -p -m 700 $workdir

# Load singularitty module from cluster LMOD 
module load singularity

# pull default image from the library if not present
if  [ "$SLURM_SERVER_CONTAINER_NAME" == "$CONTAINER_NAME" ] && [ ! -e "$CONTAINER_NAME" ]; then
    echo "singularity pull --library http://10.110.20.108 $SLURM_SERVER_CONTAINER_NAME library://$SLURM_SERVER_DEFAULT_CONTAINER_LIB" 
    singularity pull --library http://10.110.20.108 $SLURM_SERVER_CONTAINER_NAME library://$SLURM_SERVER_DEFAULT_CONTAINER_LIB
fi

# Submit job using sbatch
JOB_ID=$(sbatch --parsable $SLURM_SBATCH_OPTIONS $SLURM_SERVER_SCRIPT "$CONTAINER_NAME")

## Wait until the job has started
while true; do
    # Get the job state
    JOB_STATE=$(squeue -j $JOB_ID -h -o '%T')

    if [[ "$JOB_STATE" == "RUNNING" ]]; then
        # Print the slurm job id to cancel it when finished
        echo "$JOB_ID"
        break  # Exit the loop
    fi

    # Check if the job has failed, completed, or been cancelled
    if [[ "$JOB_STATE" == "FAILED" ]] || [[ "$JOB_STATE" == "CANCELLED" ]] || [[ "$JOB_STATE" == "COMPLETED" ]]  || [[ "$JOB_STATE" == "PREEMPTED" ]]; then
        # Print the error message to stderr and exit with error
        echo "Error: Job $JOB_ID has ended with state: $JOB_STATE" >&2
        exit 1  # Exit with a non-zero error code
    fi

    sleep 1  # Wait before rechecking
done