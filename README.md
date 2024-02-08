# AutoBomb: Penetration Testing Automation Framework

AutoBomb is a powerful penetration testing automation framework designed to streamline and simplify the process of conducting security assessments. By automating the execution of various security tools and scripts, AutoBomb empowers security professionals to efficiently discover vulnerabilities and weaknesses in target systems.

## Features

- Automates the execution of popular security tools such as WebTech, Nuclei, Nmap, Nikto, and more.
- Provides a modular and extensible architecture for adding custom tools and scripts.
- Simplifies the setup and configuration process with a centralized JSON configuration file.
- Utilizes Docker containers for isolating engagements, ensuring tool compatibility, and facilitating easy updates.

## Tools Used

AutoBomb integrates the following security tools and scripts:

- WebTech
- WebAnalyze
- Nuclei
- ParamSpider
- NucleiFuzzer
- Nmap
- Nikto
- Subfinder
- TestSSL
- Ffuf

## How it Works

1. **Setup**: Clone the AutoBomb repository to your local machine.
2. **Configuration**: Customize the `config.json` file to specify the target URL, cookies, project name, and other parameters.
3. **Execution**: Run the `autobomb.py` script to initiate the automated security assessment.
4. **Analysis**: Review the generated logs and reports to identify vulnerabilities and security issues.

## Usage

### Prerequisites

- Docker installed on your system.
- Basic understanding of penetration testing concepts and tools.

### Installation

1. Clone the AutoBomb repository:
   ```bash
   git clone https://github.com/sidthoviti/autobomb.git
   ```
2. Navigate to the clone directory:
   ```bash
   cd autobomb
   ```
3. Build the Docker image:
   ```bash
   docker build -t autobomb .
   ```
### Execution
- Run a temporary Docker container, mounting the logs directory and executing the autobomb.py script:
  ```
  docker run -v /usr/share/wordlist/dirbuster/:/app/autobomb/wordlists -v $(pwd)/logs:/app/autobomb/logs -it autobomb /bin/bash
  ```
### Customization
- Modify the config.json file to customize parameters such as the target URL, cookies, and project name.
- Add or remove tools from the automation pipeline by editing the autobomb.py script.

### Benefits of Docker 
Using Docker containers offers several advantages for penetration testing:

- Isolation: Each engagement runs in its own isolated environment, preventing interference between different assessments.
- Compatibility: Docker ensures consistent tool execution across different operating systems and environments.
- Portability: Docker images can be easily shared and deployed on different machines, enabling collaboration and scalability.
- Ease of Updates: Updating tools and dependencies is simplified with Docker, ensuring that the framework remains up-to-date with the latest security research and developments.
