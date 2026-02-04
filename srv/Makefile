# Setup
env: 
	./scripts/docker/generate-env-files.sh 

# Docker management
up:
	./scripts/docker/manage.sh start
down:
	./scripts/docker/manage.sh stop
logs:
	./scripts/docker/manage.sh logs
ps:
	./scripts/docker/manage.sh status

# Certificates
certificates:
	./scripts/certificates/generate-certificates.sh

# Database
rescan:
	./scripts/config/occ.sh files:scan --all

# Nextcloud maintenance
maintenance-on:
	./scripts/config/occ.sh maintenance:mode --on

maintenance-off:
	./scripts/config/occ.sh maintenance:mode --off

# Backup
backup:
	./scripts/backup/borg-backup.sh

list-backups:
	./scripts/backup/borg-list-backups.sh

restore:
	./scripts/backup/restore-borg-backup.sh $(name)
