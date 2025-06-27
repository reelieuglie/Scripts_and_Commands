#!/bin/bash
# Userdata script to install nvidia drivers and packages for deep learning
if (arch | grep -q x86); then
  ARCH=x86_64
else
  ARCH=sbsa
fi
VER=$(dnf list kernel-headers --showduplicates| grep -E "^\s*kernel-headers" | awk '{print $2}' | sort -V | tail -1)
###
# Update to Kernel 6.12
###

if [ ! -f /home/ec2-user/reboot ]; then
echo "Installing Kernel"
dnf install -y kernel6.12 kernel6.12-modules-extra-$VER
touch /home/ec2-user/reboot
cloud-init clean
grubby --set-default "/boot/vmlinuz-$VER.x86_64"
reboot
fi
####
# Add Repositories
####

if (! dnf search nvidia | grep -q nvidia-container-toolkit); then
  dnf config-manager --add-repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
fi
if (arch | grep -q x86); then
  ARCH=x86_64
else
  ARCH=sbsa
fi
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/amzn2023/$ARCH/cuda-amzn2023.repo
####
# Install Packages
####
dnf install -y git make kernel-devel kernel-headers  kernel-modules-extra kernel-modules-extra-common vulkan-devel libglvnd-devel elfutils-libelf-devel xorg-x11-server-Xorg kernel6.12 dkms docker --releasever=latest
systemctl enable --now dkms docker
usermod -aG docker ec2-user

####
# Install NVIDIA packages
####
dnf module install -y nvidia-driver:open-dkms
dnf install -y cuda-toolkit nvidia-container-toolkit


### NVIDIA Installer
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/570.169/NVIDIA-Linux-x86_64-570.169.run
chmod +x NVIDIA-Linux-x86_64-570.169.run

