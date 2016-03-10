#!/usr/bin/env bash

if ! rpm -qa | grep -qw ansible;
then
    echo "-> Installing Ansible"
    # Add Ansible Repository & Install Ansible
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    sudo rpm -Uvh epel-release-*.rpm
    sudo sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo

    # Install Ansible
    sudo yum -y install ansible

    # Add SSH key
    cat /ansible/files/authorized_keys >> /home/vagrant/.ssh/authorized_keys
else
        echo "-> Ansible already Installed!"
fi

# Install Ansible Galaxy modules
# To review in furure: http://docs.ansible.com/ansible/galaxy.html#id12
echo "-> Installing Ansibe Galaxy Modules"
roles_list[8]='geerlingguy.git,1.1.0'

for role_and_version in "${roles_list[@]}"
do
    role_and_version_for_grep="${role_and_version/,/, }"

    if ! sudo ansible-galaxy list | grep -qw "$role_and_version_for_grep";
    then
            echo "Installing ${role_and_version}"
            sudo ansible-galaxy -f install $role_and_version
    else
        echo "Already installed ${role_and_version}"
    fi
done

# Execute Ansible
echo "-> Execute Ansible"
sudo ansible-playbook /ansible/playbook_test.yml -e hostname=$1 -i /ansible/inventories/hosts --connection=local
