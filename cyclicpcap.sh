#!/bin/bash

# Configuration
interface="eth0"  # Replace with your network interface
duration=60        # Capture duration per file (seconds)
packets_per_file=1000 # Number of packets per file (or leave empty to capture by time)
num_files=12       # Number of cyclic capture files
base_filename="capture" # Base filename for the pcap files
output_dir="."      # Directory to save the pcap files (defaults to current directory)

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop for the specified number of files
for i in $(seq 1 $num_files); do
  filename="$output_dir/$base_filename$i.pcap"

  # Construct the tshark command
  tshark_cmd="tshark -i $interface -w $filename"

  # Capture by duration OR packets.  Uncomment the one you want.
  # Capture by duration:
  tshark_cmd+=" -a duration:$duration"

  # Capture by number of packets:
  #tshark_cmd+=" -c $packets_per_file"


  echo "Starting capture $i of $num_files: $filename"

  # Run tshark in the background
  $tshark_cmd &
  tshark_pid=$!  # Get the PID of the tshark process

  # Wait for the capture to finish (either duration or packet count)
  wait $tshark_pid

  echo "Capture $i finished."

done

echo "Cyclic capture complete."

# Optional:  If you want to merge the files at the end:
# mergecap -w merged_capture.pcap $output_dir/$base_filename*.pcap
