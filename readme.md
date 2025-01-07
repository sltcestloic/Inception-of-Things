# Setup VM

## Installation de Debian

- [Télécharger debian](https://www.debian.org/releases/stable/debian-installer/) (netinst CD image, AMD64)
- Sur VirtualBox, créer une nouvelle VM et cocher Skip Unattended Installation
- Faire une installation graphique de Debian, ne pas oublier de cocher l'installation du serveur SSH pendant l'installation

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

# Ajout d'un shared-folder entre la VM et son poste

Configurer le dossier partagé dans les settings de la VM et le mettre en `auto-mount` et `permanent` (ça marche vraiment en réalité donc on va le faire à la main)

Noter le nom du shared-folder.

Installer les packages requis par VBox Guest User Additions sur la machine invité :

```sh
apt install make gcc dkms linux-source linux-headers-$(uname -r)
```

Lancer la commande suivante pour monter le dossier partagé :
```sh
mount -t vboxsf [shared-folder name] [path to mount location]
```

Si la mount location n'existe pas, la créer avec mkdir au préalable.

Éditer le fichier `/etc/fstab` pour rendre le mount permanent en ajoutant :
```sh
[shared-folder name]	[path to mount location]	vboxsf	defaults	0	0
```

# Installation de Vagrant

```sh
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```
### Génerer une clef ssh qui sera utile pour se connecter sur les VM sans mot de passe
```sh
ssh-keygen -t rsa -b 4096
````

# Installation de [kubectl](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/) (WiP)

```sh
apt-get install curl
curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```
