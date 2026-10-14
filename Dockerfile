
FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       locales openssh-server wget ca-certificates \
    && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
    && wget -q \
       https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
       -O /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    ': "${ROOT_PASSWORD:?Set ROOT_PASSWORD in Railway Variables}"' \
    ': "${CLOUDFLARE_TUNNEL_TOKEN:?Set CLOUDFLARE_TUNNEL_TOKEN in Railway Variables}"' \
    'echo "root:${ROOT_PASSWORD}" | chpasswd' \
    '/usr/sbin/sshd' \
    'exec cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TUNNEL_TOKEN"' \
    > /usr/local/bin/start-vps \
    && chmod +x /usr/local/bin/start-vps

EXPOSE 22

CMD ["/usr/local/bin/start-vps"]
