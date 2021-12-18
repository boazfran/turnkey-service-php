#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# install Docker
echo "Enabling HTTPS.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-api \
		sh -c 'a2dissite -q default-ssl.conf && a2ensite -q 000-default.conf && service apache2 reload'
echo "Done"
echo

