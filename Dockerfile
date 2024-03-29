# Use Kali Linux as the base image
FROM kalilinux/kali-rolling

# Update Packages
RUN apt-get update -y

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    tar \
    make \
    nano \
    pv \
    ipcalc \
    lolcat \
    git \
    jq \
    python3 \
    python3-pip \
    whois \
    nmap \
    dirsearch \
    unzip \
    ccze \
    libpcap0.8-dev \
    libuv1-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Go
ENV GOLANG_VERSION 1.22.0
RUN wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz && \
    rm go$GOLANG_VERSION.linux-amd64.tar.gz

# Set Go environment variables
ENV GOPATH="$HOME/go-workspace"
ENV GOROOT="/usr/local/go"
ENV PATH="$PATH:$GOROOT/bin/:$GOPATH/bin"

# Clone the autobomb repository
RUN git clone https://github.com/sidthoviti/autobomb.git /app/autobomb

# Set the working directory
WORKDIR /app/autobomb

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

# Install Nikto
RUN apt-get install nikto -y

# Run updates for tools
RUN webanalyze -update
RUN nuclei -up && nuclei
RUN subfinder -up
RUN httpx -up

