# Docker management
up:
	docker compose up -d
down:
	docker compose down
logs:
	docker compose logs -f
ps:
	docker compose ps

restart-nextcloud:
	docker compose restart nextcloud caddy collabora collabora 

# Certificates
certificates:
	./scripts/generate-certificates.sh

# Database
rescan:
	./scripts/occ.sh files:scan --all

# Nextcloud maintenance
maintenance-on:
	./scripts/occ.sh maintenance:mode --on

maintenance-off:
	./scripts/occ.sh maintenance:mode --off

# Backup
backup:
	./scripts/backup/borg-backup.sh

list-backups:
	./scripts/backup/borg-list-backups.sh

restore:
	./scripts/backup/restore-borg-backup.sh $(name)

# Server access
start-ssh: 	
	cd ./ssh && docker compose up -d
