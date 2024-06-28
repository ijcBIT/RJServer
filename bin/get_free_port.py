import socket
import argparse

def find_port_in_range(start, end):
    for port in range(start, end + 1):
        s = socket.socket()
        try:
            s.bind(('', port))
            s.close()
            return port
        except:
            continue
    raise RuntimeError('No available ports in the specified range')

try:

    # Create ArgumentParser object
    parser = argparse.ArgumentParser()

    # Add arguments
    parser.add_argument('port_range_start', type=int, help='Start of the port range (inclusive)')
    parser.add_argument('port_range_end', type=int, help='End of the port range (inclusive)')

    # Parse arguments from command line
    args = parser.parse_args()

    port = find_port_in_range(args.port_range_start, args.port_range_end)
    print(port)
except Exception as e:
    print(e)
    exit(1)