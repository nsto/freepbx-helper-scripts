#!/bin/bash

# Prompt for a username and password
read -p "Enter a new username: " myUserName
read -s -p "Enter a new password for $myUserName: " myPassword; echo

# Prompt for your GitLab username
read -p "Enter your GitLab username: " myGitLabUsername

# Create user account and add user to wheel and asterisk group
useradd --create-home $myUserName --password $myPassword
gpasswd -a $myUserName wheel
gpasswd -a $myUserName asterisk

# Create .ssh directory, add authorized_keys file, set permissions
mkdir /home/$myUserName/.ssh
wget -O /home/$myUserName/.ssh/authorized_keys https://gitlab.com/$myGitLabUsername/public_keys/-/raw/master/authorized_keys
chown -R $myUserName:$myUserName /home/$myUserName/.ssh
chmod 700 /home/$myUserName/.ssh
chmod 600 /home/$myUserName/.ssh/authorized_keys

# Disable root login
sed -i 's/#\?\(PerminRootLogin\s*\).*$/\1 no/' /etc/ssh/sshd_config
# Disable PasswordAuthentication
# Ends up with duplicate PasswordAuthentication because it modifies both #PasswordAuthentication and PasswordAuthentication
sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
systemctl restart sshd

echo "Root setup complete. Please log out from the root user and continue with the user just set up."
