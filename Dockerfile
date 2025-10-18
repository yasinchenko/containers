FROM ubuntu:22.04

ENV container=docker
SHELL ["/bin/bash", "-lc"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      systemd systemd-sysv openssh-server sudo python3 python3-apt \
      ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH
RUN mkdir -p /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Пользователь для Ansible
RUN useradd -m -s /bin/bash ansible && echo 'ansible:ansible' | chpasswd && \
    usermod -aG sudo ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-ansible

EXPOSE 22

# Запуск systemd как PID 1
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
