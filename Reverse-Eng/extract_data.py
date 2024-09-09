import subprocess
import re
import json

def run_binwalk(binary_path):
    """Run binwalk on the specified binary and return its output."""
    result = subprocess.run(['binwalk', binary_path], capture_output=True, text=True)
    return result.stdout

def parse_binwalk_output(output):
    """Parse the binwalk output and extract relevant fields."""
    data = {}

    # Regular expressions for matching
    patterns = {
        'header_size': r'header size: ([^,]+)',
        'created': r'created: ([^,]+)',
        'image_size': r'image size: ([^,]+)',
        'OS': r'OS: ([^,]+)',
        'CPU': r'CPU: ([^,]+)',
        'image_type': r'image type: ([^,]+)',
        'compression_type': r'compression type: ([^,]+)',
        'image_name': r'image name: "([^"]+)"'
    }

    for key, pattern in patterns.items():
        match = re.search(pattern, output)
        if match:
            data[key] = match.group(1)

    return data

def main(binary_path):
    """Main function to run binwalk, parse output, and save as JSON."""
    binwalk_output = run_binwalk(binary_path)
    extracted_data = parse_binwalk_output(binwalk_output)
    
    # Output JSON to file
    with open('details.json', 'w') as json_file:
        json.dump(extracted_data, json_file, indent=2)

    print("Data extracted and saved to details.json")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python extract_data.py <path_to_binary>")
        sys.exit(1)

    binary_path = sys.argv[1]
    main(binary_path)

