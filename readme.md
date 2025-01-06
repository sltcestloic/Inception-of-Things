# Setup VM

## Installation de Debian

- [Télécharger debian](https://www.debian.org/releases/stable/debian-installer/) (netinst CD image, AMD64)
- Sur VirtualBox, créer une nouvelle VM et cocher Skip Unattended Installation
- Ne pas oublier de cocher l'installation du serveur SSH pendant l'installation

## Configuration SSH

### Port forwarding

- `ip a | grep enp0s3` -> copier l'addresse inet
- Éteindre la VM
- Dans VirtualBox, aller dans network, vérifier que Attached to est bien en NAT
- Aller dans port forwarding, ajouter une règle: 

    |  Host IP | Host Port  | Guest IP  | Guest Port  |
    |---|---|---|---|
    |  127.0.0.1 | 4242  | (coller l'ip)  | 22  |
- Relancer la VM

### Pour pouvoir se connecter directement en root sur la VM

- Installer vim (`apt-get install vim`)
- `vim /etc/ssh/sshd_config`
- Ajouter `PermitRootLogin yes`
- `systemctl restart ssh`

# Installation de Vagrant

```sh
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```