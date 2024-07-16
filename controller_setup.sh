# Setup Sudoers
touch /etc/sudoers.d/rhel_sudoers
echo "%rhel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/rhel_sudoers

# Copy over ssh keys for communication
cp -a /root/.ssh/* /home/rhel/.ssh/.
chown -R rhel:rhel /home/rhel/.ssh

# Set up repos
sudo dnf config-manager --set-disabled rhui-rhel-8-for-x86_64-baseos-rhui-rpms
sudo dnf config-manager --set-disabled rhui-rhel-8-for-x86_64-appstream-rhui-rpms
sudo dnf config-manager --enable ansible-automation-platform

sudo bash -c 'cat >/etc/yum.repos.d/centos8-baseos.repo <<EOL
[centos8-baseos]
name=CentOS 8 Stream BaseOS
baseurl=http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os
enabled=1
gpgcheck=0

EOL
cat /etc/yum.repos.d/centos8-baseos.repo'

sudo bash -c 'cat >/etc/yum.repos.d/centos8-appstream.repo <<EOL
[centos8-appstream]
name=CentOS 8 Stream AppStream
baseurl=http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/
enabled=1
gpgcheck=0

EOL
cat /etc/yum.repos.d/centos8-appstream.repo'

# Install Ansible goodies
sudo dnf clean all
sudo dnf install -y ansible-navigator ansible-lint
pip3.9 install yamllint

USER=rhel

# Clone the F5 Lab from Github
runuser --login rhel --command "git clone https://github.com/f5devcentral/f5-bd-ansible-labs.git"


loginctl enable-linger rhel
echo "Attempting to pull the EE"
# Lets go ahead and grab the EE for the F5 Lab
runuser --login rhel --command "podman pull quay.io/cnorvill/f5-101-min:v1.0; podman images"
echo "Done Attempting to pull the EE"

# set ansible-navigator default settings for rhel user
su - $USER -c 'cat >/home/$USER/f5-bd-ansible-labs/ansible-navigator.yml <<EOL
---
ansible-navigator:
  ansible:
    inventory:
      entries:
      - /home/$USER/f5-bd-ansible-labs/lab_inventory/hosts
  execution-environment:
    container-engine: podman
    enabled: true
    image: quay.io/cnorvill/f5-101-min:v1.0
    pull:
      policy: missing
    volume-mounts:
      - dest: /tmp/f5/
        src: /f5/code-output/
  logging:
    level: debug
  mode: stdout
  playbook-artifact:
    enable: false

EOL
cat /home/$USER/f5-bd-ansible-labs/ansible-navigator.yml'

# Copy the ansible-navigator.yml to ~/.ansible-navigator.yml for a fallback config
cp /home/$USER/f5-bd-ansible-labs/ansible-navigator.yml /home/$USER/.ansible-navigator.yml
chown rhel:rhel /home/$USER/.ansible-navigator.yml

# Lets build our inventory... lets get the IP's from all nodes
export NODE1_IP=`getent hosts node1 | awk '{ print $1 }'`
export NODE2_IP=`getent hosts node2 | awk '{ print $1 }'`
export BIGIP_IP=`getent hosts big-ip | awk '{ print $1 }'`
export CONTROLLER_IP=`hostname -i | awk '{print $2}'`

# Create the lab_inventory directory where the hosts file will live
runuser --login rhel --command "mkdir -p /home/$USER/f5-bd-ansible-labs/lab_inventory"
touch /home/$USER/f5-bd-ansible-labs/lab_inventory/hosts
chown -R rhel:rhel /home/$USER/f5-bd-ansible-labs/lab_inventory/hosts

runuser --login rhel --command "mkdir -p /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all"
touch /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all/connections.yml
chown -R rhel:rhel /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all/connections.yml

echo "node1_ip: $NODE1_IP" >> /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all/connections.yml
echo "node2_ip: $NODE2_IP" >> /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all/connections.yml
echo "bigip_ip: $BIGIP_IP" >> /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all/connections.yml
echo "controller_ip: $CONTROLLER_IP" >> /home/$USER/f5-bd-ansible-labs/lab_inventory/group_vars/all/connections.yml

su - $USER -c 'cat >>/home/$USER/f5-bd-ansible-labs/lab_inventory/hosts <<EOL
[all:vars]
ansible_user="rhel"
ansible_password="ansible123!"
ansible_port=22
ansible_become_pass="{{ ansible_password }}"
ansible_python_interpreter=/usr/bin/python3

[lb]
f5 ansible_host="{{ bigip_ip }}" ansible_user=admin server_port=8443

[control]
ansible ansible_host="{{ controller_ip }}" ansible_user=rhel

[web]
node1 ansible_host="{{ node1_ip }}"
node2 ansible_host="{{ node2_ip }}"

EOL
cat /home/$USER/f5-bd-ansible-labs/lab_inventory/hosts'


# Switch to correct Python version
/usr/sbin/alternatives --set python3 /usr/bin/python3.8

# Set controller access env variables
export CONTROLLER_HOST=localhost
export CONTROLLER_USERNAME=admin
export CONTROLLER_PASSWORD='ansible123!'
export CONTROLLER_VERIFY_SSL=false

# Create a directory for the ee image volume mount
mkdir -p /f5/code-output/
chown -R rhel:rhel /f5/code-output/

# Change the admin password on the big-ip
echo -e 'ansible123!\nansible123!' | ssh -o "StrictHostKeyChecking no" admin@big-ip modify auth password admin

# Get playbook from repo
#/usr/bin/curl https://raw.githubusercontent.com/leogallego/instruqt-lifecycle-scripts/main/controller-101-setup-playbook.yml -o /tmp/setup-scripts/getting-started-controller/getting-started-controller-setup.yml
# Use playbook to setup environment
#/bin/ansible-playbook /tmp/setup-scripts/getting-started-controller/getting-started-controller-setup.yml --tags setup-env