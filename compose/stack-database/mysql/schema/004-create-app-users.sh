#!/bin/bash

: "${GUACAMOLE_DB_USER:?GUACAMOLE_DB_USER is required}"
: "${GUACAMOLE_DB_PASSWORD:?GUACAMOLE_DB_PASSWORD is required}"
: "${BOOKSTACK_DB_USER:?BOOKSTACK_DB_USER is required}"
: "${BOOKSTACK_DB_PASSWORD:?BOOKSTACK_DB_PASSWORD is required}"

for user in "$GUACAMOLE_DB_USER" "$BOOKSTACK_DB_USER"; do
  if [[ ! "$user" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Database usernames may contain only letters, numbers, and underscores." >&2
    exit 1
  fi
done

if [[ "$GUACAMOLE_DB_USER" == "$BOOKSTACK_DB_USER" ]]; then
  echo "Guacamole and BookStack must use different database usernames." >&2
  exit 1
fi

escape_sql_string() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\'/\'\'}
  printf '%s' "$value"
}

guacamole_password=$(escape_sql_string "$GUACAMOLE_DB_PASSWORD")
bookstack_password=$(escape_sql_string "$BOOKSTACK_DB_PASSWORD")

docker_process_sql --database=mysql <<EOSQL
CREATE USER IF NOT EXISTS '${GUACAMOLE_DB_USER}'@'%' IDENTIFIED BY '${guacamole_password}';
GRANT ALL PRIVILEGES ON guacamole_db.* TO '${GUACAMOLE_DB_USER}'@'%';

CREATE USER IF NOT EXISTS '${BOOKSTACK_DB_USER}'@'%' IDENTIFIED BY '${bookstack_password}';
GRANT ALL PRIVILEGES ON bookstack_db.* TO '${BOOKSTACK_DB_USER}'@'%';
EOSQL
