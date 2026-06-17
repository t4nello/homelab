CREATE DATABASE IF NOT EXISTS bookstack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON bookstack_db.* TO 'sqadmin'@'%';


CREATE DATABASE IF NOT EXISTS guacamole_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON guacamole_db.* TO 'sqadmin'@'%';
FLUSH PRIVILEGES;