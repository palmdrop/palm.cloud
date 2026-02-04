#!/bin/bash

source /srv/server.env

set -eou pipefail

export BORG_PASSCOMMAND="cat ${BORG_PASSPHRASE_FILE}"

borg list $BORG_REPO

