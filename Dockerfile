FROM ubuntu:22.04

ENV container=docker
SHELL ["/bin/bash", "-lc"]

# Avoid interactive tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive

# Base packages: systemd, ssh, sudo, python for Ansible modules
RUN apt-get update &&     apt-get install -y --no-install-recommends         systemd systemd-sysv dbus         openssh-server sudo         python3 python3-apt         ca-certificates iproute2 iputils-ping curl vim less &&     apt-get clean && rm -rf /var/lib/apt/lists/*

# Prepare SSH
RUN mkdir -p /var/run/sshd &&     sed -ri 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' /etc/ssh/sshd_config &&     sed -ri 's/#?PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config &&     echo 'X11Forwarding no' >> /etc/ssh/sshd_config &&     echo 'UseDNS no' >> /etc/ssh/sshd_config

# Create Ansible user with passwordless sudo
RUN useradd -m -s /bin/bash ansible &&     echo 'ansible:ansible' | chpasswd &&     usermod -aG sudo ansible &&     echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-ansible &&     chmod 0440 /etc/sudoers.d/99-ansible

# Ensure systemd directories exist
VOLUME [ "/sys/fs/cgroup" ]
STOPSIGNAL SIGRTMIN+3

# Default command: run systemd as PID 1
CMD ["/sbin/init"]
