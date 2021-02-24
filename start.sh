#!/bin/bash

#set -eu -o pipefail

export DOCS_BASE_URL="$CLOUDRON_APP_ORIGIN"
# Set the admin email
#export DOCS_ADMIN_EMAIL_INIT="$CLOUDRON_MAIL_FROM"
# Set the admin password (in this example: "superSecure")
#DOCS_ADMIN_PASSWORD_INIT: "$$2a$$05$$PcMNUbJvsk7QHFSfEIDaIOjk1VI9/E7IPjTKx.jkjPxkx2EOKSoPS"
# Setup the database connection. "teedy-db" is the hostname
 # and "teedy" is the name of the database the application
# will connect to.
export DATABASE_URL="jdbc:postgresql://$CLOUDRON_POSTGRESQL_HOST:$CLOUDRON_POSTGRESQL_PORT/$CLOUDRON_POSTGRESQL_DATABASE"
export DATABASE_USER="$CLOUDRON_POSTGRESQL_USERNAME"
export DATABASE_PASSWORD="$CLOUDRON_POSTGRESQL_PASSWORD"

export DOCS_SMTP_HOSTNAME=${CLOUDRON_MAIL_SMTP_SERVER}
export DOCS_SMTP_PORT=${CLOUDRON_MAIL_SMTP_PORT}
export DOCS_SMTP_USERNAME=${CLOUDRON_MAIL_SMTP_USERNAME}
export DOCS_SMTP_PASSWORD=${CLOUDRON_MAIL_SMTP_PASSWORD}
export SMTP_FROM=${CLOUDRON_MAIL_FROM}


cd /app/code/


echo "=> Make cloudron own /run"
chown -R cloudron:cloudron /app/data
mkdir -p /app/data/jetty 
touch /app/data/jetty/jetty.state
ln  /app/data/jetty/jetty.state /app/code/jetty/jetty.state


exec /app/code/jetty/bin/jetty.sh run && \
sleep 15; && \
PGPASSWORD=${CLOUDRON_POSTGRESQL_PASSWORD} psql -h ${CLOUDRON_POSTGRESQL_HOST} -p ${CLOUDRON_POSTGRESQL_PORT} -U ${CLOUDRON_POSTGRESQL_USERNAME} \
 -d ${CLOUDRON_POSTGRESQL_DATABASE} -c "INSERT into t_config (cfg_id_c, cfg_value_c) \
VALUES('LDAP_ENABLED', 'true'), ('LDAP_HOST', '$CLOUDRON_LDAP_SERVER'), \
('LDAP_PORT', $CLOUDRON_LDAP_PORT), ('LDAP_ADMIN_DN', '$CLOUDRON_LDAP_BIND_DN'), \
('LDAP_ADMIN_PASSWORD', '$CLOUDRON_LDAP_BIND_PASSWORD'), \
('LDAP_BASE_DN', '$CLOUDRON_LDAP_USERS_BASE_DN'), \
('LDAP_DEAFULT_EMAIL', 'mail@mail.com'), \
('LDAP_FILTER', '(objectclass=user)(|(USERNAME=%uid)(USERNAME=%uid)))'), \
('LDAP_DEFAULT_STORAGE', 1024000000), ('SMTP_FROM', '$CLOUDRON_MAIL_FROM');"