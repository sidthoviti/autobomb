import json
import subprocess
import os
import urllib3

#Colors for terminal printing
RED = "\033[91m"
BLUE = "\033[94m"
YELLOW = "\033[93m"
GREEN = "\033[32m"
PURPLE = '\033[0;35m' 
CYAN = "\033[36m"
END = "\033[0m"
NC = "\033[0m"  # No Color

banner = f"""
{RED}       d8888          888            888888b.                          888      
      d88888          888            888  "88b                         888      
     d88P888          888            888  .88P                         888      
    d88P 888 888  888 888888 .d88b.  8888888K.   .d88b.  88888b.d88b.  88888b.  
   d88P  888 888  888 888   d88""88b 888  "Y88b d88""88b 888 "888 "88b 888 "88b 
  d88P   888 888  888 888   888  888 888    888 888  888 888  888  888 888  888 
 d8888888888 Y88b 888 Y88b. Y88..88P 888   d88P Y88..88P 888  888  888 888 d88P 
d88P     888  "Y88888  "Y888 "Y88P"  8888888P"   "Y88P"  888  888  888 88888P"  
                                                                                
                                                                                
                                                                                
"""
print(banner)
print(f"\n{YELLOW}Penetration Testing Automation Framework \n{GREEN}by Siddharth Thoviti")
print(f"\n{BLUE}Version: {CYAN}0.1b")
print(f"\n{BLUE}Info: {CYAN}The script is still in early development stages. Please report any bugs that you may encounter.")


# Disable SSL Warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Colors for terminal printing
YELLOW = "\033[93m"
NC = "\033[0m"  # No Color

# Read configuration from JSON file
with open("config.json") as f:
    config = json.load(f)

# Retrieve URL, Cookie, ProjectName, LogLocation, and Wordlists from config
url = config.get("URL")
cookie = config.get("Cookie")
project_name = config.get("ProjectName")
log_location = config.get("LogLocation", ".")
wordlist_path = config.get("WordlistPath", "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt")

if not url:
    print("Error: URL not provided in the config file.")
    exit(1)

# Create a directory for the project
project_directory = os.path.abspath(os.path.join(log_location, project_name))
os.makedirs(project_directory, exist_ok=True)

# Function to run a command and print status messages
def run_command(cmd, color, tool_name, log_path):
    print(f"{color}Running {tool_name}...{NC}")
    print(f"{cmd}")
    subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    print(f"{color}{tool_name} log located at {log_path}{NC}")
    print(f"Log file content:")
    subprocess.run(['cat', log_path])

# WhatWeb
whatweb_log_path = os.path.join(project_directory, 'whatweb_' + project_name)
webtech_cmd = f"whatweb {url} 2>&1 | tee {whatweb_log_path}"
run_command(whatweb_cmd, YELLOW, "WhatWeb", webtech_log_path)

# webanalyze
webanalyze_log_path = os.path.join(project_directory, 'webanalyze_' + project_name)
webanalyze_cmd = f"webanalyze -host {url} -crawl 1 2>&1 | tee {webanalyze_log_path}"
run_command(webanalyze_cmd, YELLOW, "webanalyze", webanalyze_log_path)

# Nuclei
nuclei_log_path = os.path.join(project_directory, "nuclei_" + project_name)
nuclei_cmd = f"nuclei -u {url} 2>&1 | tee {nuclei_log_path}"
run_command(nuclei_cmd, YELLOW, "Nuclei", nuclei_log_path)

# NucleiFuzzer
nf_log_path = os.path.join(project_directory, 'nf_' + project_name)
nf_cmd = f"nf -d {url} 2>&1 | tee {nf_log_path}"
run_command(nf_cmd, YELLOW, "NucleiFuzzer", nf_log_path)

# TestSSL
testssl_log_path = os.path.join(project_directory, 'testssl_' + project_name)
testssl_cmd = f"testssl --warnings off {url} 2>&1 | tee {testssl_log_path}"
run_command(testssl_cmd, YELLOW, "TestSSL", testssl_log_path)

# Nmap
nmap_log_path = os.path.join(project_directory, 'nmap_' + project_name)
nmap_cmd = f"nmap -A -T4 {url.split('://')[1]} 2>&1 | tee {nmap_log_path}"
#nmap_cmd = f"nmap -A -T4 {url} 2>&1 | tee {nmap_log_path}"
run_command(nmap_cmd, YELLOW, "Nmap", nmap_log_path)

# Fuff Directory Fuzzing
# Check if the URL ends with a page extension or has a trailing slash
if url.endswith(('/', '.php', '.html', '.htm', '.asp', '.aspx', '.jsp', '.cgi')):
    # If it ends with a page extension or has a trailing slash, remove the last part to get the directory
    ffuf_url = url.rstrip('/') + '/'  # Remove trailing slash if present, then add a new one
else:
    # If it doesn't end with a page extension and doesn't have a trailing slash, remove the last part to get the directory
    url_parts = url.rsplit('/', 1)
    if len(url_parts) == 2:
        ffuf_url = url_parts[0] + '/'  # Modify the URL for ffuf
    else:
        ffuf_url = url  # Use the original URL if it doesn't have a path component

ffuf_log_path = os.path.join(project_directory, 'ffuf_dir_output.txt')
ffuf_cmd = f"ffuf -u {ffuf_url}FUZZ -w {wordlist_path} -mc all -c -r -sf -o {os.path.join(project_directory, 'ffuf_dir.csv')} -of csv 2>&1 | tee {ffuf_log_path}"
run_command(ffuf_cmd, YELLOW, "Ffuf", ffuf_log_path)
#ffuf_cmd = f"ffuf -u {url}/FUZZ -w {wordlist_path} -mc all -c -r -sf -o {os.path.join(project_directory, 'ffuf_dir.csv')} -of csv 2>&1 | tee {ffuf_log_path}"

# Nikto
nikto_log_path = os.path.join(project_directory, "nikto_" + project_name)
nikto_cmd = f"nikto -host {url} 2>&1 | tee {nikto_log_path}"
run_command(nikto_cmd, YELLOW, "Nikto", nikto_log_path)

# Subfinder
#subfinder_log_path = os.path.join(project_directory, 'subfinder_' + project_name)
#subfinder_cmd = f"subfinder -d {url} 2>&1 | tee {subfinder_log_path}"
#run_command(subfinder_cmd, YELLOW, "Subfinder", subfinder_log_path)

