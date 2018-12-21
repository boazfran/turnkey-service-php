#!/bin/sh

export FILE_PATH=`realpath "$1"`
export FILE_FOLDER=`dirname "$FILE_PATH"`
export FILE_NAME=`basename "$FILE_PATH"`

sudo -E docker-compose run  \
			-e FILE_NAME="$FILE_NAME" \
			-e FILE_FOLDER="$FILE_FOLDER" \
			ireceptor-dataloading  \
				sh -c 'python /app/scripts/dataloader.py \
					--mapfile=/app/config/AIRR-iReceptorMapping.txt \
			 		--host=$DB_HOST \
			 		--database=$DB_DATABASE \
			 		--sample \
			 		-f /scratch/$FILE_NAME'