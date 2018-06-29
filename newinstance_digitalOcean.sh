adduser ubuntu  # adicionar usuario
usermod -aG sudo ubuntu  # dar root perm para usuario

su ubuntu  # trocar usuario
mkdir /home/ubuntu/.ssh  # criar pasta para sshkeys

### SAIR DA MAQUINA
# adicionar ssh na maquina
cat ~/Dropbox/hkn/sshkeys/hkn_do.pub | ssh -i ~/Dropbox/hkn/sshkeys/hkn_digital_ocean root@<IP> "cat >> /home/ubuntu/.ssh/authorized_keys"

## EDITAR /etc/ssh/sshd_config

PermitRootLogin without-password  # permitir login sem senha?
