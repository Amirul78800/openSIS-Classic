#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-opensis_root}"

log() { echo "[entrypoint] $*"; }

# ---------------------------------------------------------------------------
# 1. Seed kod aplikasi ke /var/www/html (volume) pada first-run sahaja.
#    Pada run seterusnya, Data.php / uploads / backups yang sedia ada dikekalkan.
# ---------------------------------------------------------------------------
if [ ! -f /var/www/html/index.php ]; then
    log "Volume /var/www/html kosong - seeding kod openSIS..."
    cp -a /usr/src/opensis/. /var/www/html/
fi
chown -R www-data:www-data /var/www/html

# ---------------------------------------------------------------------------
# 2. Initialize MariaDB data directory pada first-run sahaja.
# ---------------------------------------------------------------------------
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "${DATADIR}/mysql" ]; then
    log "Initializing MariaDB data directory di ${DATADIR}..."
    chown -R mysql:mysql "${DATADIR}"

    if command -v mariadb-install-db >/dev/null 2>&1; then
        mariadb-install-db --user=mysql --datadir="${DATADIR}" --skip-test-db >/dev/null
    else
        mysql_install_db --user=mysql --datadir="${DATADIR}" >/dev/null
    fi

    # Start mariadbd sementara untuk set root password
    mariadbd --user=mysql --datadir="${DATADIR}" --socket="${SOCKET}" --skip-networking=0 &
    TEMP_PID=$!

    log "Tunggu MariaDB sedia (first init)..."
    for i in $(seq 1 30); do
        if mysqladmin --socket="${SOCKET}" ping >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    mysql --socket="${SOCKET}" -u root <<-SQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
SQL

    mysqladmin --socket="${SOCKET}" -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "${TEMP_PID}" 2>/dev/null || true
    log "MariaDB initialized. Root password sudah di-set."
else
    chown -R mysql:mysql "${DATADIR}"
fi

# ---------------------------------------------------------------------------
# 3. Start MariaDB (untuk run sebenar) sebagai background process.
# ---------------------------------------------------------------------------
log "Starting MariaDB..."
mariadbd --user=mysql --datadir="${DATADIR}" --socket="${SOCKET}" &

for i in $(seq 1 30); do
    if mysqladmin --socket="${SOCKET}" ping >/dev/null 2>&1; then
        log "MariaDB up."
        break
    fi
    sleep 1
done

# ---------------------------------------------------------------------------
# 4. Start Apache (foreground, jadi proses utama container).
# ---------------------------------------------------------------------------
log "Starting Apache..."
exec apache2-foreground
