
# Stack
* docker
* nextcloud
* postgres
* redis
* borg

# Docker
* create docker network with ./scripts/init-docker.sh

# Nextcloud
* cron job for background tasks running with `nextcloud-cron` container

# Secrets
* YES

# Environment
* TODO


# Certificates

* generated with scripts
* has to be imported to each device

# Backups

* stored in a very safe `borg`
* run automatically with cron:
* see setup script?

```
0 2 * * * /home/palmdrop/server/scripts/backup/borg-backup.sh >> /var/log/nextcloud-backup.log 2>&1
```

* view `var/log/nextcloud-backup-log` for backup logs
* list backups with `make list-backups`


