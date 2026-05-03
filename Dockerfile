FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    nano \
    passwd \
    && rm -rf /var/lib/apt/lists/*

# SSH configuration
RUN mkdir /var/run/sshd && \
    # Enable password auth (disabled by default in Ubuntu)
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    # Block root login over SSH
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    # Show a login banner
    echo 'Banner /etc/ssh/banner' >> /etc/ssh/sshd_config

COPY docker-banner.txt /etc/ssh/banner

# Create students group
RUN groupadd students

# Deploy game files (including hidden dot-files)
COPY game/ /opt/comets-mystery/
RUN chown -R root:root /opt/comets-mystery && \
    find /opt/comets-mystery -type f -exec chmod 444 {} \; && \
    find /opt/comets-mystery -type d -exec chmod 555 {} \;

# Copy setup scripts so the entrypoint can use them
COPY setup/ /opt/setup/
RUN chmod +x /opt/setup/*.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
