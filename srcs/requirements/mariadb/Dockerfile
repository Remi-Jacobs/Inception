FROM alpine:3.22

# Accept values from docker-compose or env file
ARG DB_NAME
ARG DB_USER
ARG DB_PASS
ARG DB_ROOT
ARG FORCE_DB_REINIT

RUN apk update && apk add --no-cache mariadb mariadb-client net-tools

# Prepare directories and permissions
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    chmod 770 /run/mysqld

# Create MariaDB configuration that allows network connections
RUN { echo '[mariadb]'; \
      echo 'bind-address = 0.0.0.0'; \
      echo 'port = 3306'; \
      echo ''; \
      echo '[mysqld]'; \
      echo 'skip-host-cache'; \
      echo 'skip-name-resolve'; \
      echo 'bind-address = 0.0.0.0'; \
      echo 'port = 3306'; \
      echo 'socket = /run/mysqld/mysqld.sock'; \
      echo 'datadir = /var/lib/mysql'; \
      echo 'user = mysql'; \
      echo 'general_log = 0'; \
      echo 'slow_query_log = 0'; \
      echo 'skip-networking = 0'; \
    } > /etc/my.cnf.d/docker.cnf

# Copy startup script
COPY requirements/mariadb/conf/create_db.sh /create_db.sh
RUN chmod +x /create_db.sh

EXPOSE 3306

ENTRYPOINT ["/create_db.sh"]
