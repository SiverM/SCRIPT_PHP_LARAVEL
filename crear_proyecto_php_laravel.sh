#!/bin/bash
#Autor: Iver Medina
#Crear un host virtual en Nginx y un proyecto con laravel
input_type=""
input_name=""
echo "==================== PHP - LARAVEL ===================="
echo "1. Proyecto php"
echo "2. Proyecto laravel"
read -p "Elija una opcion: " input_type


if (($input_type == 1)); then
        # == CREACION DEL PROYECTO PHP ==
        # ingreso del nombre del proyecto PHP a crear
        read -p "Ingrese el nombre del proyecto PHP: " input_name
        # estructura del archivo de configuracion del proyecto para el servidor nginx
        conf_php_nginx=(
                "server {"
                "       listen 80;"
                "       listen [::]:80;"
                "       root /var/www/php/$input_name;"
                "       index index.php index.html index.htm index.nginx-debian.html;"
                "       server_name php.$input_name.com;"
                "       location / {"
                "               try_files \$uri \$uri/ =404;"
                "       }"
                "       location ~ \.php$ {"
                "               include snippets/fastcgi-php.conf;"
                "               fastcgi_pass unix:/run/php/php7.4-fpm.sock;"
                "       }"
                "       location ~ /\.ht {"
                "               deny all;"
                "       }"
                "}"
        )
        # creando el archivo de configuracion del proyecto para el servidor nginx
        input_server="php.$input_name.com"
        cd /etc/nginx/sites-available
        touch "$input_server"
        for i in ${!conf_php_nginx[@]}; do
                echo "${conf_php_nginx[$i]}" >> $input_server
        done
        cd /etc/nginx/sites-enabled
        ln -s /etc/nginx/sites-available/$input_server .
        nginx -s reload
        # creando un host virtual para el proyecto
        ipaddr=$(exec /bin/hostname -I)
        cd /etc
        echo "$ipaddr $input_server" >> hosts
        # creando la carpeta del proyecto PHP
        cd /var/www/php
        mkdir $input_name
        # == ESTABLECIENDO LOS PERMISOS DE GRUPO Y USUARIO AL PROYECTO PHP ==
        user=$(logname)
        group="www-data"
        # cambiando el grupo y usuario en la carpeta del proyecto PHP
        chown -R $user:$group /var/www/php/$input_name
        # creando un archivo .php de prueba
        cd $input_name
        touch index.php
        echo "<?php phpinfo(); ?>" >> index.php
        # == CONFIRMACION DEL PROYECTO CREADO ==
        echo "Proyecto PHP $input_name creado satisfactoriamente."
        echo "Direccion archivo de configuracion: /etc/nginx/sites-available/$input_server"
        echo "Direccion del proyecto: /var/www/php/$input_name"
        echo "Direccion web del proyecto: $input_server"
fi

if (($input_type == 2)); then
        # == CREACION DEL PROYECTO LARAVEL ==
        # ingreso del nombre del proyecto y la version de laravel
        read -p "Ingrese el nombre del proyecto LARAVEL: " input_name
        read -p "Ingrese la version de laravel para el proyecto nuevo: " input_version
        # estructura del archivo de configuracion del proyecto para el servidor nginx
        conf_php_nginx=(
                "server {"
                "       listen 80;"
                "       listen [::]:80;"
                "       root /var/www/laravel/$input_name/public;"
                "       index index.php index.html index.htm index.nginx-debian.html;"
                "       server_name laravel.$input_name.com;"
                "       location / {"
                "               try_files \$uri \$uri/ /index.php?\$query_string;"
                "       }"
                "       location ~ \.php$ {"
                "               include snippets/fastcgi-php.conf;"
                "               fastcgi_pass unix:/run/php/php7.4-fpm.sock;"
                "       }"
                "       location ~ /\.ht {"
                "               deny all;"
                "       }"
                "}"
        )
        # creando el archivo de configuracion del proyecto para el servidor nginx
        input_server="laravel.$input_name.com"
        cd /etc/nginx/sites-available
        touch "$input_server"
        for i in ${!conf_php_nginx[@]}; do
                echo "${conf_php_nginx[$i]}" >> $input_server
        done
        cd /etc/nginx/sites-enabled
        ln -s /etc/nginx/sites-available/$input_server .
        nginx -s reload
        # creando un host virtual para el proyecto
        ipaddr=$(exec /bin/hostname -I)
        cd /etc
        echo "$ipaddr $input_server" >> hosts
        # creando el proyecto laravel con composer
        cd /var/www/laravel
        composer create-project laravel/laravel $input_name $input_version.*
        # == ESTABLECIENDO LOS PERMISOS DE GRUPO Y USUARIO AL PROYECTO LARAVEL ==
        user=$(logname)
        group="www-data"
        # cambiando el grupo y usuario en la carpeta del proyecto laravel
        chown -R $user:$group /var/www/laravel/$input_name
        # Establecer los permisos correctos para los archivos
        find /var/www/laravel/$input_name -type f -exec chmod 644 {} \;
        # Establecer los permisos correctos para los directorios
        find /var/www/laravel/$input_name -type d -exec chmod 755 {} \;
        # Establecer grupo de servidores web para storage + cache folders
        chgrp -R $group /var/www/laravel/$input_name/storage /var/www/laravel/$input_name/bootstrap/cache
        # Establecer los permisos correctos para storage + cache folders
        chmod -R ug+rwx /var/www/laravel/$input_name/storage /var/www/laravel/$input_name/bootstrap/cache
        # == CONFIRMACION DEL PROYECTO CREADO ==
        echo "Proyecto LARAVEL $input_name creado satisfactoriamente."
        echo "Direccion archivo de configuracion: /etc/nginx/sites-available/$input_server"
        echo "Direccion del proyecto: /var/www/laravel/$input_name"
        echo "Direccion web del proyecto: $input_server"
fi