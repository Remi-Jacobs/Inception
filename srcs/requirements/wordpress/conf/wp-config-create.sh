#!/bin/sh
set -e

echo "[WordPress] Starting WordPress configuration..."

# Wait for MariaDB to be ready
echo "[WordPress] Waiting for MariaDB to be ready..."
for i in $(seq 1 30); do
    if mysqladmin ping -h mariadb -u"${DB_USER}" -p"${DB_PASS}" --silent; then
        echo "[WordPress] MariaDB is ready!"
        break
    fi
    echo "[WordPress] Waiting for MariaDB... ($i/30)"
    sleep 2
done

# Test database connection
if ! mysqladmin ping -h mariadb -u"${DB_USER}" -p"${DB_PASS}" --silent; then
    echo "[WordPress] ERROR: Cannot connect to MariaDB after 60 seconds"
    echo "[WordPress] DB_NAME: ${DB_NAME}"
    echo "[WordPress] DB_USER: ${DB_USER}"
    echo "[WordPress] DB_HOST: mariadb"
    exit 1
fi

# Only create wp-config.php if it doesn't exist
if [ ! -f "/var/www/wp-config.php" ]; then
cat << EOF > /var/www/wp-config.php
<?php
define( 'DB_NAME', '${DB_NAME}' );
define( 'DB_USER', '${DB_USER}' );
define( 'DB_PASSWORD', '${DB_PASS}' );
define( 'DB_HOST', 'mariadb' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define('FS_METHOD','direct');

\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

    echo "[WordPress] wp-config.php created."
else
    echo "[WordPress] wp-config.php already exists, skipping creation."
fi

# Test WordPress database connection one more time
echo "[WordPress] Testing WordPress database connection..."
php84 -r "
\$db = new mysqli('mariadb', '${DB_USER}', '${DB_PASS}', '${DB_NAME}');
if (\$db->connect_error) {
    echo '[WordPress] Database connection failed: ' . \$db->connect_error . PHP_EOL;
    exit(1);
} else {
    echo '[WordPress] Database connection successful!' . PHP_EOL;
}
\$db->close();
"

echo "[WordPress] Configuration complete, starting PHP-FPM..."
