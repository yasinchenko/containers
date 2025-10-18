# Systemd-ready образ для Ubuntu 22.04
FROM jrei/systemd-ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

# Пакеты для SSH и Ansible
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-server sudo \
      python3 python3-apt \
      ca-certificates iproute2 iputils-ping curl vim less && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Настройки SSH
RUN mkdir -p /var/run/sshd && \
    sed -ri 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#?PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config && \
    echo 'UseDNS no' >> /etc/ssh/sshd_config

# Пользователь для Ansible с sudo без пароля
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    usermod -aG sudo ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-ansible && \
    chmod 0440 /etc/sudoers.d/99-ansible

# Включаем SSH-сервис
RUN systemctl enable ssh

# В этом образе systemd уже PID 1, CMD трогать не нужно
