#!/bin/bash

# Configuration
OLLAMA_MODEL="deepseek-ai/deepseek-1.5B"  # Replace with your Ollama model name
BCAP_DIR="/path/to/your/bcap/frames" # Replace with the directory containing your bcap files
OUTPUT_FILE="security_evaluation.txt" # Output file for results

# Function to evaluate a single frame (bcap file)
evaluate_frame() {
  local frame_file="$1"
  local frame_name=$(basename "$frame_file")

  # Extract relevant information from the bcap file.  This is highly dependent
  # on your bcap format. You'll likely need to use tools like tcpdump, wireshark,
  # or tshark to parse the bcap and extract the data you want to send to the LLM.
  #
  # Example using tshark (replace with your actual extraction commands):
  #  This example extracts source and destination IPs and ports. Adapt as needed.

  src_ip=$(tshark -r "$frame_file" -T fields -e ip.src | head -n 1)
  dst_ip=$(tshark -r "$frame_file" -T fields -e ip.dst | head -n 1)
  src_port=$(tshark -r "$frame_file" -T fields -e tcp.srcport | head -n 1) # Example TCP port
  dst_port=$(tshark -r "$frame_file" -T fields -e tcp.dstport | head -n 1) # Example TCP port
  # ... extract other relevant information ...


  # Construct the prompt for the LLM
  prompt="Analyze the following network traffic data for potential security breaches:\n\
  Frame: $frame_name\n\
  Source IP: $src_ip\n\
  Destination IP: $dst_ip\n\
  Source Port: $src_port\n\
  Destination Port: $dst_port\n\
  # ... include other extracted information ...\n\
  Identify any suspicious activity or security risks.  Explain your reasoning.  Provide a concise summary of the findings (e.g., 'Potential port scan detected', 'No apparent issues', etc.)."

  # Send the prompt to Ollama
  response=$(ollama run "$OLLAMA_MODEL" -p "$prompt")

  # Append the results to the output file
  echo "Frame: $frame_name" >> "$OUTPUT_FILE"
  echo "Prompt: $prompt" >> "$OUTPUT_FILE" # Optional: include the prompt
  echo "Response: $response" >> "$OUTPUT_FILE"
  echo "------------------------------------" >> "$OUTPUT_FILE"

}


# Loop through all bcap files in the directory
find "$BCAP_DIR" -name "*.bcap" -print0 | while IFS= read -r -d $'\0' frame_file; do
  evaluate_frame "$frame_file"
done

echo "Evaluation complete. Results saved to $OUTPUT_FILE"
