# openSIS Classic — Docker Edition

Production-ready, containerized distribution of [openSIS Classic](https://www.os4ed.com/) Community Edition v9.3. Pre-configured with automated database connectivity, an Apache/PHP runtime, and turnkey Docker Compose orchestration.

[![Docker CI](https://github.com/Amirul78800/openSIS-Classic/actions/workflows/docker-ci.yml/badge.svg)](https://github.com/Amirul78800/openSIS-Classic/actions)
[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](https://github.com/OS4ED/openSIS-Classic/blob/master/docs/License.txt)

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
