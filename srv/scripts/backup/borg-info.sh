#!/bin/bash

set -eou pipefail

source /srv/server.env

export BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"

borg info $BORG_REPO
