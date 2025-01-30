# Setup VM

## Installation de Debian

- [Télécharger debian](https://www.debian.org/releases/stable/debian-installer/) (netinst CD image, AMD64)
- Sur VirtualBox, créer une nouvelle VM et cocher Skip Unattended Installation
- Faire une installation graphique de Debian, ne pas oublier de cocher l'installation du serveur SSH pendant l'installation

## Configuration SSH

### Port forwarding

- `ip a | grep enp0s3` -> copier l'addresse inet
- Dans VirtualBox, aller dans network, vérifier que Attached to est bien en NAT
- Aller dans port forwarding, ajouter une règle: 

    |  Host IP | Host Port  | Guest IP  | Guest Port  |
    |---|---|---|---|
    |  127.0.0.1 | 4242  | (coller l'ip)  | 22  |

### Pour pouvoir se connecter directement en root sur la VM

- Installer vim (`apt-get install vim -y`)
- `vim /etc/ssh/sshd_config`
- Ajouter `PermitRootLogin yes`
- `systemctl restart ssh`

# Ajout d'un shared-folder entre la VM et son poste

Configurer le dossier partagé dans les settings de la VM et le mettre en `auto-mount` et `permanent` (ça marche vraiment en réalité donc on va le faire à la main)

Noter le nom du shared-folder.

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
sudo apt update && sudo apt install vagrant -y
```
### Génerer une clef ssh qui sera utile pour se connecter sur les VM sans mot de passe
```sh
ssh-keygen -t rsa -b 4096
````

### Installer [VirtualBox](https://linuxiac.com/how-to-install-virtualbox-on-debian-12-bookworm/)

```
wget -O- -q https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmour -o /usr/share/keyrings/oracle_vbox_2016.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update
sudo apt install virtualbox-7.1 -y
```

### Activer la Nested Virtualization
Pour faire fonctionner Vagrant dans la VM, il va falloir activer la nested virtualization dans les paramètres de VirtualBox

Aller dans **System -> Processor** et cocher **Enable Nested VT-x/AMD-V**

Relancer la VM

# Ajout des hosts pour la p2

```sh
echo 192.168.58.110 app1.com app2.com app3.com >> /etc/hosts
```

# Installation de [kubectl](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/)

```sh
apt-get install curl -y
curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```
