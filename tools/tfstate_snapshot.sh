#!/bin/bash
INFRA_MASTER_DIR="../../InfraMaster"
TFSTATE_PATH="../HomeOpsData/terraform.tfstate"
NAME="HomeOps"

# ---
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/../"

PHASE=$1
SOURCE="${TFSTATE_PATH}"
WORKDIR="${INFRA_MASTER_DIR}"
TARGET="${INFRA_MASTER_DIR}/tfstate/${NAME}.tfstate"
NOW=`date +"%s = %Y-%m-%d %H:%M:%S"`

cmp $SOURCE $TARGET > /dev/null 2>&1
if [ $? -ne 0 ]; then
  cp $SOURCE $TARGET
  cd $INFRA_MASTER_DIR
  ./encrypt_and_stage.sh
  git commit -m "[auto] Snapshot of ${NAME} at ${NOW} triggered ${PHASE} ${TG_CTX_COMMAND}"
  git push
else
  echo "No changes in tfstate detected, not creating snapshot."
fi
