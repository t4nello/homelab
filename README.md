ansible-vault encrypt group_vars/vault/management.yml -J


ansible-playbook playbooks/deploy-management.yml --ask-become-pass -J -vvv