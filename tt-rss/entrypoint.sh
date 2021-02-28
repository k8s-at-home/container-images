#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

export PGPASSWORD=$TTRSS_DB_PASS 

while ! pg_isready -h $TTRSS_DB_HOST -U $TTRSS_DB_USER; do
	echo waiting until $TTRSS_DB_HOST is ready...
	sleep 3
done


# Create schema if not already set
PSQL="psql -q -h $TTRSS_DB_HOST -U $TTRSS_DB_USER $TTRSS_DB_NAME"
$PSQL -c "create extension if not exists pg_trgm"

if ! $PSQL -c 'select * from ttrss_version'; then
	$PSQL < /app/schema/ttrss_schema_pgsql.sql
fi

# PHP in debug mode
if [ ! -z "${TTRSS_XDEBUG_ENABLED}" ]; then
	if [ -z "${TTRSS_XDEBUG_HOST}" ]; then
		export TTRSS_XDEBUG_HOST=$(ip ro sh 0/0 | cut -d " " -f 3)
	fi
	echo enabling xdebug with the following parameters:
	env | grep TTRSS_XDEBUG
	cat > /etc/php/7.4/conf.d/50_xdebug.ini <<EOF
zend_extension=xdebug.so
xdebug.mode=develop,trace,debug
xdebug.start_with_request = yes
xdebug.client_port = ${TTRSS_XDEBUG_PORT}
xdebug.client_host = ${TTRSS_XDEBUG_HOST}
EOF
fi

sudo -E -u www-data php /app/update.php --update-schema=force-yes

touch $DST_DIR/.app_is_ready


#Start web server with php support
/usr/sbin/php-fpm7.4
/usr/sbin/nginx ${EXTRA_ARGS}

exec sudo -E -u www-data php /app/update_daemon2.php