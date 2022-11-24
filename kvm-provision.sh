#!/bin/bash

##Define your env, like a path,etc..


VM_NAME="kworker1"
USERNAME="arya"
PASSWORD="arya"
CPU="1"
MEMORY="1024"
PATH="/AR"


#mkdir -p $PATH/images/templates
##Download cloud image ubuntu()
#wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -O $PATH/images/templates/ubuntu20server.qcow2

echo "[Convert & Copy Image] $VM_NAME"
mkdir -p $PATH/images/$VM_NAME \
&& qemu-img convert \
-f qcow2 \
-O qcow2 \
$PATH/images/templates/ubuntu20-server.qcow2 \
$PATH/images/$VM_NAME/root-disk.qcow2

echo "[Resize Disk...]"
qemu-img resize $PATH/images/$VM_NAME/root-disk.qcow2 20G

echo "[Create Cloud-Init Config...]"
echo "#cloud-config
system_info:
  default_user:
    name: $USERNAME
    home: /home/$USERNAME

password: $PASSWORD
chpasswd: { expire: False }
hostname: $VM_NAME

# configure sshd to allow users logging in using password
# rather than just keys
ssh_pwauth: True
" | sudo tee $PATH/images/$VM_NAME/cloud-init.cfg > /dev/null

echo "[Convert Cloud-Init Config...]"
cloud-localds \
$PATH/images/$VM_NAME/cloud-init.iso \
$PATH/images/$VM_NAME/cloud-init.cfg

echo "[VM $VM_NAME lagi dibuat..]"
virt-install \
  --name $VM_NAME \
  --memory $MEMORY \
  --disk $PATH/images/$VM_NAME/root-disk.qcow2,device=disk,bus=virtio \
  --disk $PATH/images/$VM_NAME/cloud-init.iso,device=cdrom \
  --os-variant ubuntu20.04 \
  --virt-type kvm \
  --graphics none \
  --noautoconsole \
  --network network=br-net\
  --import
