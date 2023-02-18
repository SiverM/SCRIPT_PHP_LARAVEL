#!/bin/bash
#Autor: Iver Medina
#Crear un host virtual en Nginx y un proyecto con laravel
input_type=""
input_name=""
pause=""
option=1
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
GREEN='\033[0;32m'
while [ $option -ne 0 ]
do
clear
echo -e "${RED}========================= HTML - PHP - LARAVEL =========================${NC}"
echo -e "	${YELLOW}1.${NC} Proyecto HTML"
echo -e "	${YELLOW}2.${NC} Proyecto PHP"
echo -e "	${YELLOW}3.${NC} Proyecto LARAVEL"
echo -e "	${YELLOW}4.${NC} Listar proyectos"
echo -e "	${YELLOW}5.${NC} Eliminar un proyecto"
echo -e "	${YELLOW}6.${NC} Salir"
read -p "Elija una opcion: " input_type

if (($input_type == 1)); then
	clear
	# == CREACION DEL PROYECTO HTML ==
	echo -e "${CYAN}========================= NUEVO PROYECTO HTML =========================${NC}"
        # ingreso del nombre del proyecto PHP a crear
        read -p "Ingrese el nombre del proyecto HTML: " input_name
        # estructura del archivo de configuracion del proyecto para el servidor nginx
        conf_html_nginx=(
                "server {"
                "       listen 80;"
                "       listen [::]:80;"
                "       root /var/www/html/$input_name;"
                "       index index.html index.htm index.nginx-debian.html;"
                "       server_name html.$input_name.com;"
                "       location / {"
                "               try_files \$uri \$uri/ =404;"
                "       }"
                "}"
        )
        # creando el archivo de configuracion del proyecto para el servidor nginx
        input_server="html.$input_name.com"
        cd /etc/nginx/sites-available
        touch "$input_server"
        for i in ${!conf_html_nginx[@]}; do
                echo "${conf_html_nginx[$i]}" >> $input_server
        done
	cd /etc/nginx/sites-enabled
        ln -s /etc/nginx/sites-available/$input_server .
        nginx -s reload
        # creando un host virtual para el proyecto
        ipaddr=$(exec /bin/hostname -I)
        cd /etc
        echo "$ipaddr $input_server" >> hosts
        # creando la carpeta del proyecto PHP
        cd /var/www/html
        mkdir $input_name
        # == ESTABLECIENDO LOS PERMISOS DE GRUPO Y USUARIO AL PROYECTO PHP ==
        user=$(logname)
        group="www-data"
        # Agregar al usuario actual al grupo del servidor
        usermod -a -G $group $user
        # cambiando el grupo y usuario en la carpeta del proyecto PHP
        chown -R $user:$group /var/www/html/$input_name .
        # asignando permisos 664 a los archivos y de 775 a los directorios
        find /var/www/html/$input_name -type f -exec chmod 644 {} \;
        find /var/www/html/$input_name -type d -exec chmod 755 {} \;
        # creando un archivo .php de prueba
        cd $input_name
        touch index.html
        echo "<h1>Nuevo proyecto $input_name</h1>" >> index.html
        # == CONFIRMACION DEL PROYECTO CREADO ==
        echo -e "${GREEN}Proyecto HTML $input_name creado satisfactoriamente.${NC}"
        echo -e "${GREEN}Direccion archivo de configuracion: /etc/nginx/sites-available/$input_server${NC}"
        echo -e "${GREEN}Direccion del proyecto: /var/www/html/$input_name${NC}"
        echo -e "${GREEN}Direccion web del proyecto: $input_server${NC}"
	read -p "presione una tecla para regresar al menu principal." pause
fi

if (($input_type == 2)); then
	clear
	# == CREACION DEL PROYECTO PHP ==
	echo -e "${CYAN}========================= NUEVO PROYECTO PHP =========================${NC}"
	# ingreso del nombre del proyecto PHP a crear
	read -p "Ingrese el nombre del proyecto PHP: " input_name
	# estructura del archivo de configuracion del proyecto para el servidor nginx
	conf_php_nginx=(
		"server {"
		"	listen 80;"
		"	listen [::]:80;"
		"	root /var/www/php/$input_name;"
		"	index index.php index.html index.htm index.nginx-debian.html;"
		"	server_name php.$input_name.com;"
		"	location / {"
		"		try_files \$uri \$uri/ =404;"
		"	}"
		"	location ~ \.php$ {"
		"		include snippets/fastcgi-php.conf;"
		"		fastcgi_pass unix:/run/php/php7.4-fpm.sock;"
		"	}"
		"	location ~ /\.ht {"
		"		deny all;"
		"	}"
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
	# Agregar al usuario actual al grupo del servidor
	usermod -a -G $group $user
	# cambiando el grupo y usuario en la carpeta del proyecto PHP
        chown -R $user:$group /var/www/php/$input_name .
	# asignando permisos 664 a los archivos y de 775 a los directorios
	find /var/www/php/$input_name -type f -exec chmod 644 {} \;
	find /var/www/php/$input_name -type d -exec chmod 755 {} \;
	# creando un archivo .php de prueba
	cd $input_name
	touch index.php
	echo "<?php phpinfo(); ?>" >> index.php
	# == CONFIRMACION DEL PROYECTO CREADO ==
	echo -e "${GREEN}Proyecto PHP $input_name creado satisfactoriamente.${NC}"
	echo -e "${GREEN}Direccion archivo de configuracion: /etc/nginx/sites-available/$input_server${NC}"
	echo -e "${GREEN}Direccion del proyecto: /var/www/php/$input_name${NC}"
	echo -e "${GREEN}Direccion web del proyecto: $input_server${NC}"
	read -p "presione una tecla para regresar al menu principal." pause
fi

if (($input_type == 3)); then
	clear
	# == CREACION DEL PROYECTO LARAVEL ==
	echo -e "${CYAN}========================= NUEVO PROYECTO LARAVEL =========================${NC}"
	# ingreso del nombre del proyecto y la version de laravel
	read -p "Ingrese el nombre del proyecto LARAVEL: " input_name
	read -p "Ingrese la version de laravel para el proyecto nuevo: " input_version
	# estructura del archivo de configuracion del proyecto para el servidor nginx
	conf_laravel_nginx=(
		"server {"
		"	listen 80;"
		"	listen [::]:80;"
		"	root /var/www/laravel/$input_name/public;"
		"	index index.php index.html index.htm index.nginx-debian.html;"
		"	server_name laravel.$input_name.com;"
		"	location / {"
		"		try_files \$uri \$uri/ /index.php?\$query_string;"
		"	}"
		"	location ~ \.php$ {"
		"		include snippets/fastcgi-php.conf;"
		"		fastcgi_pass unix:/run/php/php7.4-fpm.sock;"
		"	}"
		"	location ~ /\.ht {"
		"		deny all;"
		"	}"
		"}"
	)
	# creando el archivo de configuracion del proyecto para el servidor nginx
	input_server="laravel.$input_name.com"
	cd /etc/nginx/sites-available
	touch "$input_server"
	for i in ${!conf_laravel_nginx[@]}; do
  		echo "${conf_laravel_nginx[$i]}" >> $input_server
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
	# Agregar al usuario actual al grupo del servidor
        usermod -a -G $group $user
	# cambiando el grupo y usuario en la carpeta del proyecto laravel
	chown -R $user:$group /var/www/laravel/$input_name .
	# Establecer los permisos correctos para los archivos
	find /var/www/laravel/$input_name -type f -exec chmod 644 {} \;
	# Establecer los permisos correctos para los directorios
	find /var/www/laravel/$input_name -type d -exec chmod 755 {} \;
	# Establecer grupo de servidores web para storage + cache folders
	chgrp -R $group /var/www/laravel/$input_name/storage /var/www/laravel/$input_name/bootstrap/cache
	# Establecer los permisos correctos para storage + cache folders
	chmod -R ug+rwx /var/www/laravel/$input_name/storage /var/www/laravel/$input_name/bootstrap/cache
	# == CONFIRMACION DEL PROYECTO CREADO ==
	echo -e "${GREEN}Proyecto LARAVEL $input_name creado satisfactoriamente.${NC}"
	echo -e "${GREEN}Direccion archivo de configuracion: /etc/nginx/sites-available/$input_server${NC}"
	echo -e "${GREEN}Direccion del proyecto: /var/www/laravel/$input_name${NC}"
	echo -e "${GREEN}Direccion web del proyecto: $input_server${NC}"
	read -p "presione una tecla para regresar al menu principal." pause
fi

if (($input_type == 4)); then
        clear
	# == LISTAR PROYECTOS ==
	echo -e "${CYAN}========================= LISTAR PROYECTOS =========================${NC}"
        # determinando el tipo de proyecto a listar
        echo "1. Proyecto HTML"
        echo "2. Proyecto PHP"
        echo "3. Proyecto LARAVEL"
        read -p "Elija una opcion: " input_type
        if (($input_type == 1)); then
                type="html"
		proyecto="HTML"
        fi
        if (($input_type == 2)); then
                type="php"
		proyecto="PHP"
        fi
        if (($input_type == 3)); then
                type="laravel"
		proyecto="LARAVEL"
        fi
	cd /var/www/$type
	echo " LISTA DE PROYECTOS $proyecto :"
	ls -l
	read -p "presione una tecla para regresar al menu principal." pause
fi

if (($input_type == 5)); then
	clear
	# == ELIMINACION DE UN PROYECTO ==
	echo -e "${CYAN}========================= ELIMINAR PROYECTO =========================${NC}"
        # ingreso del nombre del proyecto a eliminar
        read -p "Ingrese el nombre del proyecto a eliminar: " input_name
        # determinando el tipo de proyecto a eliminar
	echo "==================== TIPO PROYECTO A ELIMINAR ===================="
	echo "1. Proyecto HTML"
	echo "2. Proyecto PHP"
	echo "3. Proyecto LARAVEL"
	read -p "Elija una opcion: " input_type
	if (($input_type == 1)); then
		type="html"
	fi
	if (($input_type == 2)); then
		type="php"
	fi
	if (($input_type == 3)); then
		type="laravel"
	fi
	# creando el archivo de configuracion del proyecto para el servidor nginx
        input_server="$type.$input_name.com"
        cd /etc/nginx/sites-available
        rm -R $input_server
        cd /etc/nginx/sites-enabled
        rm -R $input_server
        nginx -s reload
        # eliminando el host virtual del proyecto
        cd /etc
        touch tmphosts
	chown -R iver:iver tmphosts
	grep -v "$type.$input_name.com" hosts > tmphosts
	mv tmphosts hosts
	# eliminando la carpeta del proyecto
        cd /var/www/$type
        rm -R $input_name
        # == CONFIRMACION DEL PROYECTO ELIMINADO ==
        echo -e "${GREEN}Proyecto $input_name del tipo $type eliminado satisfactoriamente.${NC}"
	read -p "presione una tecla para regresar al menu principal." pause
fi

if (($input_type == 6)); then
	option=0
	clear
fi

done