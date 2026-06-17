#!/bin/bash
set -e

ALLOW_INSTALL="${ALLOW_INSTALL:-false}"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"

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
# 2. Tunggu container DB (service 'db' dalam compose) sedia menerima sambungan
#    TCP sebelum start Apache. Guna /dev/tcp bash - tak perlu binary tambahan.
# ---------------------------------------------------------------------------
log "Tunggu DB di ${DB_HOST}:${DB_PORT}..."
for i in $(seq 1 60); do
    if (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null; then
        exec 3>&- 3<&-
        log "DB sedia."
        break
    fi
    sleep 1
    if [ "$i" -eq 60 ]; then
        log "AMARAN: DB masih tak sedia lepas 60s, terus start Apache (semak container db)."
    fi
done

# ---------------------------------------------------------------------------
# 3. Auto-lock folder /install lepas setup siap (Data.php wujud), untuk elak
#    orang luar re-run installer / purge DB. Set ALLOW_INSTALL=true untuk
#    buka semula (contoh: nak upgrade versi).
# ---------------------------------------------------------------------------
INSTALL_DIR="/var/www/html/install"
DATA_FILE="/var/www/html/Data.php"

if [ -d "${INSTALL_DIR}" ]; then
    if [ -f "${DATA_FILE}" ] && [ "${ALLOW_INSTALL}" != "true" ]; then
        if [ ! -f "${INSTALL_DIR}/.htaccess" ]; then
            log "Setup dah siap - lock folder /install (set ALLOW_INSTALL=true untuk buka semula)."
            echo "Require all denied" > "${INSTALL_DIR}/.htaccess"
            chown www-data:www-data "${INSTALL_DIR}/.htaccess"
        fi
    elif [ "${ALLOW_INSTALL}" = "true" ] && [ -f "${INSTALL_DIR}/.htaccess" ]; then
        log "ALLOW_INSTALL=true - membuka semula akses /install."
        rm -f "${INSTALL_DIR}/.htaccess"
    fi
fi

# ---------------------------------------------------------------------------
# 4. Start Apache (foreground, jadi proses utama container).
# ---------------------------------------------------------------------------
log "Starting Apache..."
exec apache2-foreground
