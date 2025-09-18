#!/bin/bash
# This script prompts for your SSH key passphrase once and caches it for a set time
# Run this before executing Ansible playbooks to avoid multiple passphrase prompts

if ! command -v ssh-agent &> /dev/null; then
    echo "ssh-agent is not installed. Please install it first."
    exit 1
fi

if ! command -v ssh-add &> /dev/null; then
    echo "ssh-add is not installed. Please install it first."
    exit 1
fi

# Check if ssh-agent is running
ssh_agent_pid=$(pgrep -u $USER ssh-agent)
if [ -z "$ssh_agent_pid" ]; then
    echo "Starting new ssh-agent..."
    eval $(ssh-agent -s)
else
    echo "ssh-agent is already running (PID: $ssh_agent_pid)"
    # If we don't have SSH_AUTH_SOCK, set it
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "Setting up SSH_AUTH_SOCK environment variable"
        export SSH_AUTH_SOCK=$(find /tmp -path "*agent*" -user $USER -name "agent.*" 2>/dev/null | head -n 1)
    fi
fi

# Check if key is already added
ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_rsa | awk '{print $2}')" 2>/dev/null
if [ $? -ne 0 ]; then
    # Add your private key (will prompt for password once)
    echo "Adding your SSH key to the agent. Enter your passphrase when prompted:"
    ssh-add ~/.ssh/id_rsa
else
    echo "SSH key is already added to the agent."
fi

echo ""
echo "SSH key added to agent. Ansible can now use your key without prompting for a passphrase."
echo "This session will remain active until you log out or kill the ssh-agent process."
echo ""
echo "You can now run your Ansible playbooks."