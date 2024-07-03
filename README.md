# RPyServer

## Overview
This repository contains two scripts to start Jupyter Notebook and RStudio Server on a High-Performance Computing (HPC) system and connect to them from your workstation. The scripts utilize Singularity container images for both Jupyter Notebook and RStudio Server, enabling an easy and consistent environment setup.

## Repository Contents
- `start_jupyter_notebook.sh`: Script to start a Jupyter Notebook server on the HPC.
- `start_rstudio_server.sh`: Script to start an RStudio Server on the HPC.

## Getting Started
To use these scripts, follow the instructions below:

### Clone the Repository
Clone the repository in your home directory on the HPC:
```bash
git clone https://github.com/ijcBIT/RPyServer.git
```

### Running the Scripts
Navigate to the cloned repository:
```bash
cd RPyServer
```

#### Start Jupyter Notebook
To start a Jupyter Notebook server, run:
```bash
./start_jupyter_notebook.sh
```

#### Start RStudio Server
To start an RStudio Server, run:

```bash
./start_rstudio_server.sh
```

### Custom Container Images
If you need to use custom container images, you can specify the container image path (.sif file), with the -c or --container parameter:

```bash
./start_jupyter_notebook.sh -c <container_image_name>
./start_rstudio_server.sh -c <container_image_name>
```

### SLURM Parameters
The scripts run the servers in a SLURM job with default resources. If you need more resources, you can pass SLURM parameters directly to the scripts. A full list of SLURM parameters can be found [here](https://slurm.schedmd.com/sbatch.html).

### Help
For help, use the -h or --help parameter:

```bash
./start_jupyter_notebook.sh -h
./start_rstudio_server.sh -h
```

## Connecting from Your Workstation
After running the scripts, follow the instructions provided by the scripts to connect to the servers from your workstation.

### Jupyter Notebook
1. Create an SSH tunnel:
    ```bash
    ssh -L 8888:{HPC_NODE}:{ASSIGNED_PORT} {USER}@minastirith
    ```
2. Open a browser and navigate to:
    ```
    http://localhost:8888/lab?token={TOKEN}
    ```

### RStudio Server
1. Create an SSH tunnel:
    ```bash
    ssh -L 8787:{HPC_NODE}:{ASSIGNED_PORT} {USER}@minastirith
    ```
2. Open a browser and navigate to:
    ```
    http://localhost:8787
    ```

## Issues and Requests
If you encounter any issues or have requests, please submit an issue on GitHub: [RPyServer Issues](https://github.com/ijcBIT/RPyServer/issues)
