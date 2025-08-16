#!/bin/sh
set -e

MYSQL_DIR="/var/lib/mysql"

echo "[MariaDB] Starting initialization..."
echo "[MariaDB] Environment - DB_NAME: ${DB_NAME}, DB_USER: ${DB_USER}"

# Force reinitialization if requested
if [ "$FORCE_DB_REINIT" = "true" ] && [ -d "$MYSQL_DIR" ]; then
    echo "[MariaDB] Removing old database files due to FORCE_DB_REINIT..."
    rm -rf "$MYSQL_DIR"/*
fi

# Initialize database if it doesn't exist
if [ ! -d "$MYSQL_DIR/mysql" ]; then
    echo "[MariaDB] Initializing database..."
    chown -R mysql:mysql "$MYSQL_DIR"
    mariadb-install-db --user=mysql --datadir="$MYSQL_DIR"

    TMPFILE=$(mktemp)
    cat << EOF > "$TMPFILE"
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Bootstrap the DB with SQL commands
    /usr/bin/mariadbd --user=mysql --bootstrap < "$TMPFILE"
    rm -f "$TMPFILE"
    echo "[MariaDB] Database initialized."
else
    echo "[MariaDB] Database already exists, skipping initialization."
fi

echo "[MariaDB] Starting server on port 3306..."
echo "[MariaDB] Configuration check:"
cat /etc/my.cnf.d/docker.cnf

# Check if port 3306 is available
if netstat -tlnp | grep :3306; then
    echo "[MariaDB] WARNING: Port 3306 already in use!"
    netstat -tlnp | grep :3306
fi

# Start MariaDB with explicit network settings and skip networking disabled
exec /usr/bin/mariadbd --user=mysql \
    --bind-address=0.0.0.0 \
    --port=3306 \
    --socket=/run/mysqld/mysqld.sock \
    --datadir=/var/lib/mysql \
    --skip-networking=0
