podman network create LAMP
podman run --name mysql -e MYSQL_ROOT_PASSWORD=diouxx -e MYSQL_DATABASE=glpidb -e MYSQL_USER=glpi_user -e MYSQL_PASSWORD=glpi -d mysql:5.7.23 --network LAMP
podman run --name glpi --publish 80:80 -d diouxx/glpi --network LAMP

