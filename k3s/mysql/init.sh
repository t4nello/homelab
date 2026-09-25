#!/bin/bash
set -e

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS bookstack_db
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_unicode_ci;

    CREATE USER IF NOT EXISTS 'bookstack_user'@'%'
        IDENTIFIED BY '${BOOKSTACK_DB_PASSWORD}';

    GRANT ALL PRIVILEGES ON bookstack_db.*
        TO 'bookstack_user'@'%';


    CREATE DATABASE IF NOT EXISTS guacamole_db
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_unicode_ci;

    CREATE USER IF NOT EXISTS 'guacamole_user'@'%'
        IDENTIFIED BY '${GUACAMOLE_DB_PASSWORD}';

    GRANT ALL PRIVILEGES ON guacamole_db.*
        TO 'guacamole_user'@'%';

    FLUSH PRIVILEGES;
EOSQL