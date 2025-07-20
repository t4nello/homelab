FROM mysql:9

COPY ../schemas/001-create-schema.sql /docker-entrypoint-initdb.d/
COPY ../schemas/002-create-admin-user.sql /docker-entrypoint-initdb.d/