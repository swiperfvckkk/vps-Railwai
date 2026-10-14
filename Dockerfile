
FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
       locales openssh-server wget unzip ca-certificates \
    && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*


ARG ngrokid
ARG Password

RUN wget -q -O /tmp/ngrok.zip \
    https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip \
    && unzip /tmp/ngrok.zip -d /usr/local/bin \
    && rm /tmp/ngrok.zip \
    && chmod 755 /usr/local/bin/ngrok

RUN mkdir -p /run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo "root:${Password}" | chpasswd \
    && printf '%s\n' \
       '#!/bin/bash' \
       'set -e' \
       'ngrok config add-authtoken "$NGROK_AUTHTOKEN"' \
       'ngrok tcp --region=jp 22 &' \
       'exec /usr/sbin/sshd -D -e' \
       > /usr/local/bin/start-vps \
    && chmod 755 /usr/local/bin/start-vps

ENV NGROK_AUTHTOKEN=""

EXPOSE 22

CMD ["/usr/local/bin/start-vps"]
