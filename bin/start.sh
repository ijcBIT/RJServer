#!/bin/bash


# Help information
usage() {
    echo "Usage: ./<script_name>.sh [OPTIONS]"
    echo "Options:"
    echo "  Any slurm parameter to pass to sbatch"
    echo "  -c, --container name      Specify container name"
    echo "                            Name of a singularity image containing ${SLUMR_SERVER_NAME}"
    echo "  -h, --help                Display this help and exit"
    exit 1
}

# Parse arguments
CONTAINER_NAME=$SLUMR_SERVER_CONTAINER_NAME
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
JOB_ID=$(sbatch --parsable $sbatch_options $SLUMR_SERVER_SCRIPT "$CONTAINER_NAME" 2>&1)

# Wait until the job has started and written something to the log file
LOG_FILE="$SLUMR_SERVER_LOG_FOLDER/$(echo $JOB_ID | cut -f 1 -d '.').log"
while ! test -s $LOG_FILE
do
    sleep 1
done
sleep 1

# Print the contents of the log file
cat $LOG_FILE

