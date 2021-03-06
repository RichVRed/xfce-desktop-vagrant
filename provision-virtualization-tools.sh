#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

# install qemu tools.
apt-get install -y qemu-utils

# install VirtualBox.
# see https://www.virtualbox.org/wiki/Linux_Downloads
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >/etc/apt/sources.list.d/virtualbox.list
apt-get update
apt-get install -y virtualbox-5.1

# install libvirt et al.
apt-get install -y virt-manager

# install Packer.
apt-get install -y unzip
packer_version=1.0.3
wget -q -O/tmp/packer_${packer_version}_linux_amd64.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip
unzip /tmp/packer_${packer_version}_linux_amd64.zip -d /usr/local/bin
# install useful packer plugins.
wget -q -O/tmp/packer-provisioner-windows-update-linux.tgz https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.3.0/packer-provisioner-windows-update-linux.tgz
tar xf /tmp/packer-provisioner-windows-update-linux.tgz -C /usr/local/bin
chmod +x /usr/local/bin/packer-provisioner-windows-update
rm /tmp/packer-provisioner-windows-update-linux.tgz

# install Vagrant.
vagrant_version=1.9.7
wget -q -O/tmp/vagrant_${vagrant_version}_x86_64.deb https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb
dpkg -i /tmp/vagrant_${vagrant_version}_x86_64.deb
rm /tmp/vagrant_${vagrant_version}_x86_64.deb
# install useful vagrant plugins.
apt-get install -y libvirt-dev
su vagrant -c bash <<'VAGRANT_EOF'
#!/bin/bash
set -eux
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-triggers
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-windows-update
VAGRANT_EOF
