#!/bin/bash
# Vérifier si l'utilisateur a fourni les paramètres nécessaires
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ServerName> <ProxyPassPort>"
    exit 1
fi

ServerName="$1"
vhost_filename=$ServerName.conf
ProxyPassPort="$2"

apt update -y
apt install -y apache2 build-essential

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_ajp
a2enmod rewrite
a2enmod deflate
a2enmod headers
a2enmod proxy_balancer
a2enmod proxy_connect
a2enmod proxy_html

# Les paramètres passés par l'utilisateur

# Le chemin du répertoire de configuration d'Apache
apache_conf_dir="/etc/apache2/sites-available"


# Le chemin complet du fichier de configuration
vhost_filepath="$apache_conf_dir/$vhost_filename"

# Le texte du VirtualHost que vous souhaitez insérer
vhost_config="
<VirtualHost *:80>
    ServerName $ServerName
    ServerAlias www.$ServerName

    ProxyPreserveHost On
    
    ProxyPass / http://0.0.0.0:$ProxyPassPort/
    ProxyPassReverse / http://0.0.0.0:$ProxyPassPort/
    
</VirtualHost>
"

# Créer le fichier de configuration et y insérer le texte
echo "$vhost_config" | sudo tee "$vhost_filepath" > /dev/null

# Activer le site
sudo a2ensite "$vhost_filename"

# Redémarrer Apache pour appliquer les changements
sudo service apache2 restart

echo "############### Configuration Apache créée avec succès pour $vhost_filename sur le port $ProxyPassPort !"

