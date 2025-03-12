FROM mysql:9

COPY mysql/schema/001-create-schema.sql /docker-entrypoint-initdb.d/
COPY mysql//schema/002-create-admin-user.sql /docker-entrypoint-initdb.d/
