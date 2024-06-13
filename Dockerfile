# Use Kali Linux as the base image
FROM kalilinux/kali-rolling:latest

# Update and Install Packages
RUN apt-get -y update \
    && apt-get install -y \
    apt-utils wget curl tar make dnsutils usbutils pciutils net-tools python3 python3-pip \
    python3-setuptools python3-wheel jq whois nano vim pv ipcalc lolcat unzip ccze zip \
    libpcap0.8-dev libuv1-dev git netcat-traditional nmap nikto ffuf gobuster impacket-scripts \
    less locate lsof man-db smbclient smbmap socat ssh-client sslscan sqlmap telnet tmux whatweb \    
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*

# Install Go
ENV GOLANG_VERSION 1.22.0
RUN wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz && \
    rm go$GOLANG_VERSION.linux-amd64.tar.gz

# enum4linux-ng
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-impacket python3-ldap3 python3-yaml \
    && mkdir /tools \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists*

WORKDIR /tools
RUN git clone https://github.com/cddmp/enum4linux-ng.git /tools/enum4linux-ng \
    && ln -s /tools/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng

# Install Seclists
RUN mkdir -p /usr/share/seclists \
    # The apt-get install seclists command isn't installing the wordlists, so clone the repo.
    && git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists

# Prepare rockyou wordlist
#RUN mkdir -p /usr/share/wordlists
#WORKDIR /usr/share/wordlists
#RUN cp /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz /usr/share/wordlists/ \
#    && tar -xzf rockyou.txt.tar.gz

# Set Go environment variables
ENV GOPATH="$HOME/go-workspace"
ENV GOROOT="/usr/local/go"
ENV PATH="$PATH:$GOROOT/bin/:$GOPATH/bin"

# Clone the autobomb repository
RUN git clone https://github.com/sidthoviti/autobomb.git /root/autobomb

# Set the working directory
WORKDIR /root/autobomb

# Install WebAnalyze
RUN go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest

# Install TestSSL
#RUN git clone --depth 1 https://github.com/drwetter/testssl.sh.git && \
#    ln -s /app/autobomb/testssl.sh/testssl.sh /usr/local/bin/testssl.sh
#RUN apt install -y testssl.sh
RUN wget https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh && \
    chmod +x testssl.sh && \
    cp testssl.sh /usr/bin/testssl

# Install Httpx
RUN go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# Install Nuclei
RUN go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Install NucleiFuzzer
RUN git clone https://github.com/0xKayala/NucleiFuzzer.git && \
    cd NucleiFuzzer && \
    chmod +x install.sh && \
    ./install.sh && \
    chmod +x NucleiFuzzer.sh && mv NucleiFuzzer.sh /usr/bin/nf

# Install ffuf
RUN go install github.com/ffuf/ffuf/v2@latest

# Install Subfinder
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Run updates for tools
RUN webanalyze -update
RUN nuclei -up && nuclei
RUN subfinder -up
#RUN httpx -update

