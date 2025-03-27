#!/bin/bash

CLUSTER_NAME="minastirith"
CLUSTER_FOLDER_NAME=".RJServer"


# Help information
usage() {
    echo "Usage: ./<script_name>.sh [OPTIONS]"
    echo "Options:"
    echo "  --                        Enter any Slurm parameter that you wish to pass to Slurm." 
    echo "                            https://slurm.schedmd.com/sbatch.html"
    echo ""                                  
    echo "                            Example:"
    echo "                            --mem=10GB --cpus-per-task=10"
    echo ""
    echo "  -c, --'container name'    Path to a Singularity image on your local workstation."
    echo "                            The image must be derived from a ${SLURM_SERVER_NAME} image."
    echo ""
    echo "  -h, --help                Display this help and exit"
    exit 1
}

# Parse arguments
CONTAINER_PATH=$SLURM_SERVER_CONTAINER_NAME
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            usage
            exit 0
            ;;
        --*=*) # --key=value or --container=value
            if [[ "$key" =~ ^--container=(.*) ]]; then
                CONTAINER_PATH="${BASH_REMATCH[1]}"
            else
                SLURM_SBATCH_OPTIONS+=" $key"
            fi
            ;;
        --*) # --key or --key value or --container or --container value
            if [[ "$key" == "--container" ]]; then
                if [[ -n "$2" && ! "$2" =~ ^-.* ]]; then
                    CONTAINER_PATH="$2"
                    shift
                else
                    echo "Error: Missing value for --container"
                    usage
                    exit 1
                fi
            elif [[ -z "$2" ]] || [[ "$2" =~ ^-.* ]]; then
                SLURM_SBATCH_OPTIONS+=" $key"
            else
                SLURM_SBATCH_OPTIONS+=" $key $2"
                shift
            fi
            ;;
        -c=*) # -c=container
            CONTAINER_PATH="${key#-c=}"
            ;;
        -c) # -c or -c container
            if [[ -n "$2" && ! "$2" =~ ^-.* ]]; then
                CONTAINER_PATH="$2"
                shift
            else
                echo "Error: Missing value for -c"
                usage
                exit 1
            fi
            ;;
        *)
            echo "Unrecognized option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

echo "SLURM_SBATCH_OPTIONS:$SLURM_SBATCH_OPTIONS"
echo "CONTAINER_PATH:$CONTAINER_PATH"
# extract container file name from the path
CONTAINER_NAME=$(basename $CONTAINER_PATH)

# Copy required files to the cluster if they are not there
if ! ssh $CLUSTER_NAME "[ -d ~/$CLUSTER_FOLDER_NAME ]"; then 
    ssh $CLUSTER_NAME "mkdir -p ~/$CLUSTER_FOLDER_NAME" && scp -r bin $CLUSTER_NAME:~/$CLUSTER_FOLDER_NAME > /dev/null 2>&1 
fi

# Copy the container if it is different from the default and if it is not already in the cluster
if [ "$CONTAINER_NAME" != "$SLURM_SERVER_CONTAINER_NAME" ] && ! ssh $CLUSTER_NAME "[ -e ~/$CLUSTER_FOLDER_NAME/$CONTAINER_NAME ]"; then
    scp $CONTAINER_PATH $CLUSTER_NAME:~/$CLUSTER_FOLDER_NAME > /dev/null 2>&1
fi

# Submit job using sbatch and capture the node where the job is running
OUTPUT=$(ssh $CLUSTER_NAME " cd $CLUSTER_FOLDER_NAME && \
    export SLURM_SBATCH_OPTIONS=\"${SLURM_SBATCH_OPTIONS}\" && \
    export CONTAINER_NAME=\"${CONTAINER_NAME}\" && \
    export SLURM_SERVER_NAME=\"${SLURM_SERVER_NAME}\" && \
    export SLURM_SERVER_SCRIPT=\"${SLURM_SERVER_SCRIPT}\" && \
    export SLURM_SERVER_CONTAINER_NAME=\"${SLURM_SERVER_CONTAINER_NAME}\" && \
    export SLURM_SERVER_DEFAULT_CONTAINER_LIB=\"${SLURM_SERVER_DEFAULT_CONTAINER_LIB}\" && \
    export SLURM_SERVER_LOG_FOLDER=\"${SLURM_SERVER_LOG_FOLDER}\" && \
    ./bin/start_job.sh $@ " 2>&1 | tee /dev/tty)

# Capture the last line as JOBID (assuming it is the job ID)
JOBID=$(echo "$OUTPUT" | tail -n 1)

# Wait one second
sleep 1  

# copy the tunnel command
scp ${CLUSTER_NAME}:~/$CLUSTER_FOLDER_NAME/tunnel.sh .

# add the cluster address
echo " $CLUSTER_NAME" >> tunnel.sh

# run the tunnel command
chmod 775 tunnel.sh
./tunnel.sh &
TUNNEL_PID=$!  # Capture the PID of the SSH tunnel process

# Print the closing instructions
cat 1>&2 <<END
A SSH tunnel from your workstation has been created. 
Close this shell when you are done to finish the job in the cluster.

END

# open the browser session
xdg-open http://localhost:$LOCAL_PORT


# Function to clean up the tunnel
cleanup() {
    echo "Cleaning up: Terminating the SSH tunnel $TUNNEL_PID..."
    kill -9 $TUNNEL_PID 2>/dev/null  # Attempt to kill the tunnel
    echo "Cleaning up: Quilling the job $JOBID in the cluster with the server"
    ssh $CLUSTER_NAME "scancel $JOBID" 
    rm tunnel.sh
    exit 0    
}

# Trap termination signals (SIGINT, SIGTERM)
trap cleanup SIGINT SIGTERM

# This will bring the SSH process back to the foreground and hold the script
wait $TUNNEL_PID  

