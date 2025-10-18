# Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash","-lc"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo python3 python3-apt ca-certificates \
    iproute2 iputils-ping curl vim less netcat && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH: включаем пароли, root по паролю запрещаем
RUN mkdir -p /var/run/sshd && \
    sed -ri 's/#?PasswordAuthentication .*/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#?PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config && \
    echo 'UseDNS no' >> /etc/ssh/sshd_config && \
    ssh-keygen -A

# Пользователь для Ansible
RUN useradd -m -s /bin/bash ansible && echo 'ansible:ansible' | chpasswd && \
    usermod -aG sudo ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-ansible && \
    chmod 0440 /etc/sudoers.d/99-ansible

EXPOSE 22

# Запускаем sshd как PID 1
CMD ["/usr/sbin/sshd","-D","-e"]
