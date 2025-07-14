Prepare vault pass
prepare management/etc passwords

encrypt with:
ansible-vault create --vault-password-file homelab/ansible/secrets/.vault_pass.txt homelab/ansible/secrets/management.yml
