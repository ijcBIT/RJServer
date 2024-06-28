#!/bin/bash

SCRIPT="./rstudio_server.slm"
CONTAINER_NAME="rstudio_latest.sif"

# Help information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  Any slurm parameter to pass to sbatch"
    echo "  -c, --container name      Specify container name"
    echo "  -h, --help                Display this help and exit"
    echo "Container_name:"
    echo "  Name of a singularity image containing rstudio server. Defaults to the basic image."
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            usage
            exit 0
            ;;
        --*=*) # --key=value or --container=value
            if [[ "$key" =~ ^--container=(.*) ]]; then
                CONTAINER_NAME="${BASH_REMATCH[1]}"
            else
                sbatch_options+=" $key"
            fi
            ;;
        --*) # --key or --key value or --container or --container value
            if [[ "$key" == "--container" ]]; then
                if [[ -n "$2" && ! "$2" =~ ^-.* ]]; then
                    CONTAINER_NAME="$2"
                    shift
                else
                    echo "Error: Missing value for --container"
                    usage
                    exit 1
                fi
            elif [[ -z "$2" ]] || [[ "$2" =~ ^-.* ]]; then
                sbatch_options+=" $key"
            else
                sbatch_options+=" $key $2"
                shift
            fi
            ;;
        -c=*) # -c=container
            CONTAINER_NAME="${key#-c=}"
            ;;
        -c) # -c or -c container
            if [[ -n "$2" && ! "$2" =~ ^-.* ]]; then
                CONTAINER_NAME="$2"
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

# Submit job using sbatch
JOB_ID=$(sbatch --parsable $sbatch_options $SCRIPT "$CONTAINER_NAME" 2>&1)

# Wait until the job has started and written something to the log file
LOG_FILE="rstudio_server/$(echo $JOB_ID | cut -f 1 -d '.').log"
while ! test -s $LOG_FILE
do
    sleep 1
done
sleep 1

# Print the contents of the log file
cat $LOG_FILE

