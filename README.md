# openSIS Classic — Docker Edition

Production-ready, containerized distribution of [openSIS Classic](https://www.os4ed.com/) Community Edition v9.3. Pre-configured with automated database connectivity, an Apache/PHP runtime, and turnkey Docker Compose orchestration.

[![Docker CI](https://github.com/Amirul78800/openSIS-Classic/actions/workflows/docker-ci.yml/badge.svg)](https://github.com/Amirul78800/openSIS-Classic/actions)
[![GitHub Release](https://img.shields.io/github/v/release/Amirul78800/openSIS-Classic?style=flat-square&color=blue)](https://github.com/Amirul78800/openSIS-Classic/releases)
[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg?style=flat-square)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![openSIS Version](https://img.shields.io/badge/openSIS-v9.3_Classic-orange?style=flat-square)](https://opensis.com/)
[![Docker Compose](https://img.shields.io/badge/Docker-Compose_Ready-2496ED?logo=docker&logoColor=white&style=flat-square)](docker-compose.yml)
[![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?logo=php&logoColor=white&style=flat-square)](https://www.php.net/)
[![MariaDB](https://img.shields.io/badge/MariaDB-10.6+-003545?logo=mariadb&logoColor=white&style=flat-square)](https://mariadb.org/)
[![Docker Hub](https://img.shields.io/badge/dockerhub-opensis--classic-blue?logo=docker&style=flat-square)](https://hub.docker.com/r/amirul123/opensis-classic)
[![Docker Pulls](https://img.shields.io/docker/pulls/amirul123/opensis-classic?style=flat-square)](https://hub.docker.com/r/amirul123/opensis-classic)
[![Docker Image Size](https://img.shields.io/docker/image-size/amirul123/opensis-classic/latest?style=flat-square)](https://hub.docker.com/r/amirul123/opensis-classic)
---

## Why This Fork?

Deploying openSIS Classic on bare-metal systems often encounters PHP module mismatches, permission hurdles, and manual Apache virtual host configurations. 

This repository packages openSIS Classic v9.3 into an automated Docker workflow:
* **Zero Configuration Friction:** Uses entrypoint scripts to configure database credentials dynamically via environment variables.
* **Persistent Storage:** Keeps student records, system logs, attachments, and MariaDB tables isolated in named volumes across container recreations.
* **Isolated Networking:** Places the web server and database within an internal container network, exposing only the specified application port to the host.

---

## Quick Start with Docker Compose

### 1. Clone the Repository

```bash
git clone -b deployment-v2 [https://github.com/Amirul78800/openSIS-Classic.git](https://github.com/Amirul78800/openSIS-Classic.git)
cd openSIS-Classic
```
### 2. Configure Environment Variables

Copy the sample environment file to create your local .env:
cp example.env .env
Adjust the credentials in .env if needed (see Environment Variables below).

## 3. Launch the Stack

```bash
docker compose up -d
```
Once running, access the openSIS web portal at:
```bahs
http://localhost:8080
```
(Replace `8080` with the `CONTAINER_PORT` configured in your `.env` file).

## 4.Environment Variables (.env)

| Variable | Example Value | Description |
| :--- | :--- | :--- |
| CONTAINER_PORT | 8080 | Host port mapped to the Apache web server |
| DB_HOST | db | Database service hostname in Docker network |
| DB_NAME | opensis | Target MariaDB database name for openSIS |
| DB_USER | opensis | Dedicated database user account |
| DB_PASSWORD | opensis_secure_pass | Password for the dedicated database user |
| DB_ROOT_PASSWORD | mariadb_root_pass | Root administrative password for MariaDB |

## 5.First-Time Setup & Installation

1. Navigate to `http://localhost:8080` in your browser.
2. Follow the on-screen openSIS setup wizard.
3. When prompted for database settings:
 - Host: db
 - Database Name: `opensis` (or your `$DB_NAME`)
 - Database User: `opensis` (or your `$DB_USER`)
 - Database Password: Value of `$DB_PASSWORD`
4. Complete the administrative account creation and initial school setup.

## 6.Volume Persistence & Data Locations

To ensure data integrity during container restarts and upgrades, two persistent volumes are mounted:
 1. `db-data` (`/var/lib/mysql`): Stores the MariaDB system tables and openSIS relational databases.
 2. `opensis-data` (`/var/www/html` or specific attachment folders): Holds uploaded student photos, school records, generated reports, and configuration files.

## 7.Operations & Maintenance

# Database Backup
Export a full database dump to a timestamped SQL file:
```bash
docker compose exec db mysqldump -u root -p${DB_ROOT_PASSWORD} opensis > backup_opensis_$(date +%F).sql
```
# Database Restore
Restore an existing SQL backup file into the running MariaDB container:
```bash
docker compose exec -T db mysql -u root -p${DB_ROOT_PASSWORD} opensis < backup_opensis.sql
```
# Viewing Container Logs
To monitor Apache, PHP runtime, or database logs in real time:
```bash
# Web application logs
docker compose logs -f opensis
# MariaDB database logs
docker compose logs -f db
```

# Stopping and Restarting
```bash
# Stop containers without losing data
docker compose down
# Start containers again
docker compose up -d
```

## 8.License & Attribution

openSIS Classic is licensed under the GNU General Public License v2.0.
This fork provides container packaging, Docker automation, and deployment configurations only. It is not officially affiliated with or endorsed by Open Solutions for Education, Inc. (OS4ED).
