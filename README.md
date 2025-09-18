# Homelab Ansible Configuration

This repository contains Ansible configurations for managing my homelab infrastructure, including a Proxmox mini PC and Raspberry Pi, along with VMs running on Proxmox.

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── ssh-init.sh              # Script to initialize SSH key for password-protected keys
├── inventory/               # Inventory files
│   ├── hosts                # Main inventory file
│   ├── group_vars/          # Variables for groups of hosts
│   └── host_vars/           # Variables for specific hosts
├── playbooks/               # Playbooks for different tasks
│   ├── 01-create_ansible_user.yml    # Create standardized ansible user
│   ├── 02-setup-fail2ban.yml         # Install and configure fail2ban
│   ├── 03-install-docker.yml         # Install Docker
│   ├── 04-configure-vms.yml          # Configure VMs
│   ├── 05-update-vms.yml             # Update systems
│   └── tbd/                          # Playbooks under development
└── roles/                   # Role definitions
    ├── common/              # Common tasks for all hosts
    ├── fail2ban/            # Fail2ban installation and configuration
    ├── update/              # System update routines
    └── vm_management/       # VM-specific management tasks
```

## Initial Setup

1. **Update the inventory file** with your actual host information:
   - Edit `inventory/hosts` to add your Proxmox, Raspberry Pi, and VM IP addresses

2. **Initialize your SSH key** before running playbooks (needed for password-protected keys):
   ```
   ./ssh-init.sh
   ```

3. **Test connectivity** to your hosts:
   ```
   ansible all -m ping
   ```

## Available Playbooks

### User Management

- **01-create_ansible_user.yml**: Creates a standardized ansible user with SSH key authentication
  ```
  ansible-playbook playbooks/01-create_ansible_user.yml
  ```

### Security

- **02-setup-fail2ban.yml**: Install and configure fail2ban on hosts
  ```
  ansible-playbook playbooks/02-setup-fail2ban.yml
  ```

### Infrastructure

- **03-install-docker.yml**: Install Docker on target hosts
  ```
  ansible-playbook playbooks/03-install-docker.yml
  ```

### VM Management

- **04-configure-vms.yml**: Configure newly created VMs with baseline settings
  ```
  ansible-playbook playbooks/04-configure-vms.yml -e "target_group=new_vms"
  ```

- **05-update-vms.yml**: Update all systems and reboot if necessary
  ```
  ansible-playbook playbooks/05-update-vms.yml
  ```

## Roles

### Common

The `common` role provides baseline configuration for all hosts, including:
- Common utility packages
- Basic security configuration
- System time setup

### Fail2ban

The `fail2ban` role:
- Installs and configures the fail2ban service
- Deploys a customized jail configuration
- Handles different service names across distributions
- Protects SSH and other configured services from brute force attacks

### Update

The `update` role:
- Performs system updates across different distributions
- Handles package cache updates
- Manages service restarts when needed
- Performs controlled system reboots if required

### VM Management

The `vm_management` role:
- Setups qemu-guest-agent
- Sets up vm hostname
- Installs additional packages

## Adding New Hosts

1. Add the new host to `inventory/hosts` under the appropriate group
2. Create host-specific variables in `host_vars/` if needed
3. Run the appropriate playbooks to configure the host:
   ```
   ansible-playbook playbooks/01-create_ansible_user.yml -l new_host
   ansible-playbook playbooks/02-setup-fail2ban.yml -l new_host
   ```

## Security Notes

- The setup uses your local SSH key which should be password-protected
- SSH key authentication is enforced with the ansible user
- SSH password authentication is disabled by default for security
- Fail2ban is configured to protect against brute force attacks

## Running Specific Roles

To run a specific role only (for example, just the fail2ban role):
```
ansible-playbook -i inventory/hosts playbooks/02-setup-fail2ban.yml --tags "fail2ban"
```

## Requirements

- Ansible 2.10 or newer
- SSH access to the hosts
- Python 3 installed on the managed hosts
- Password-protected SSH key for authentication
