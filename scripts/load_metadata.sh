#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
DATALOADING_POD=`oc get pod | grep ireceptor-dataloading | awk '{print $1}'`
DB_HOST="ireceptor-database"
DB_DATABASE="ireceptor"

# check number of arguments
NB_ARGS=2
if [ $# -ne $NB_ARGS ];
then
    echo "$0: wrong number of arguments ($# instead of $NB_ARGS)"
    echo "usage: $0 (ireceptor|repertoire) <metadata_file.csv>"
    exit 1
fi

REPERTOIRE_TYPE="$1"
shift

FILE_ABSOLUTE_PATH=`realpath "$1"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`
FILE_PATH=`basename $(dirname ~/dev/turnkey-service-php.git/)`/${FILE_NAME}

# copy the content of the file folder to the scratch directory on the pod
oc rsync ${FILE_FOLDER} ${DATALOADING_POD}:/scratch

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

echo "Loading file $1"
echo "Starting at: $TIME1"

# Notes:
# sudo -E: make environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container
# (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be
# substituted only when the python command is executed, INSIDE the container

CMD="python3.6 /app/dataload/dataloader.py -v \
		--mapfile=/app/config/AIRR-iReceptorMapping.txt \
		--host=$DB_HOST \
		--database=$DB_DATABASE \
		--repertoire_collection sample \
		--$REPERTOIRE_TYPE \
		-f /scratch/$FILE_PATH"
CMD="oc exec ${DATALOADING_POD} -- sh -c '${CMD}' 2>&1 | tee ${LOG_FILE}"
echo ${CMD}
`${CMD}`


TIME2=`date +%Y-%m-%d_%H-%M-%S`
echo "Finished at $TIME2"
