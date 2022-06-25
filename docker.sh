#!/bin/bash

# 패키지
sudo apt-get install -y curl
sudo apt-get install -y apt-transport-https
sudo apt-get install -y ca-certificates
sudo apt-get install -y gnupg-agent
sudo apt-get install -y software-properties-common
sudo apt-get install -y gnupg2  
sudo apt-get install -y lsb-release

# GPG key 등록
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 저장소 등록
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 도커엔진 패키지 업데이트
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 도커엔진 버전 설치
sudo apt-get install -y docker-ce=5:20.10.17~3-0~ubuntu-focal docker-ce-cli=5:20.10.17~3-0~ubuntu-focal containerd.io

#도커 테스트
sudo docker run hello-world

# swap 제거
swapoff -a

# cgroup 변경
touch daemon.json
cat > daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo chown root:root daemon.json
sudo mv ./daemon.json /etc/docker/.

# docker service
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl enable docker


# grub update
sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cgroup_enable=memory swapaccount=1\"/" /etc/default/grub
update-grub
shutdown -r now

