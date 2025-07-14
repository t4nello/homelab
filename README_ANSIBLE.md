Prepare vault pass
prepare management/etc passwords

encrypt with:
ansible-vault create --vault-password-file homelab/ansible/secrets/.vault_pass.txt homelab/ansible/secrets/management.yml

 ANSIBLE_VAULT_PASSWORD_FILE=secrets/.vault_pass.txt ansible-playbook playbooks/deploy-management.yml
   88  ANSIBLE_VAULT_PASSWORD_FILE=secrets/.vault_pass.txt ansible-playbook playbooks/deploy-management.yml -vvv