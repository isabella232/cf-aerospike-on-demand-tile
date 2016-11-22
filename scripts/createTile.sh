#!/bin/bash
#set -xv

function realpath() {
      [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
ROOT_DIR=$SCRIPT_DIR/..

SERVICE_ADAPTER_DIR=$ROOT_DIR/cf-aerospike-service-adapter-release
SERVICE_RELEASE_DIR=$ROOT_DIR/cf-aerospike-service-release

if [ ! -d "${SERVICE_ADAPTER_DIR}" ] ; then
  echo "ERROR:"
  echo "$SERVICE_ADAPTER_DIR not found."
  echo "Execute 'git submodule update --init' to initialize the submodules"
  exit -1
fi

pushd on-demand-broker
  BROKER_NAME=`find . -name *.tgz | awk -F"-" '{ print $5 }'`
  SERVICE_BROKER_VERSION="${BROKER_NAME%.*}"
popd

if [ -z "$BROKER_NAME" ]; then
  echo "ERROR:"
  echo "On-demand-broker not found."
  echo "Get the latest on-demand-broker tgz from Pivotal and copy to the on-demand-broker directory"
  exit -1
fi

if [ "$#" -gt 1 ]; then
  echo "Usage: [<version>]"
  echo " 1st arg (optional): version of the tile (i.e. 0.0.1)"
  echo ""
  echo " Check sample props files under ${SCRIPT_DIR}/templates folder for creating the input files"
  exit -1
fi

# Read versions from service and service-adapter submodules
source $SCRIPT_DIR/product_version
if [ "$#" -gt 0 ]; then
  PRODUCT_VERSION="$1"
  printf "PRODUCT_VERSION=%s\n" $PRODUCT_VERSION > $SCRIPT_DIR/product_version
else
  # Increment current version and save it back out
  perl -i -pe 's/PRODUCT_VERSION=\d+\.\d+\.\K(\d+)/ $1+1 /e' $SCRIPT_DIR/product_version
  source $SCRIPT_DIR/product_version
fi

# Create the release for the service adapter
pushd $SERVICE_ADAPTER_DIR
  ./scripts/createRelease.sh
popd

# Create the release for the service release
pushd $SERVICE_RELEASE_DIR
  ./scripts/createRelease.sh
popd

source $SERVICE_ADAPTER_DIR/scripts/version
source $SERVICE_RELEASE_DIR/scripts/version

RELEASE_DIR=$(realpath $ROOT_DIR)
OUTPUT_DIR=$(realpath $ROOT_DIR)
TEMPLATES_DIR=$ROOT_DIR/tile-templates

# Source the product properties
PRODUCT_NAME=aerospike-on-demand-service

TILE_FILE_FULL_PATH=`ls $TEMPLATES_DIR/aerospike-on-demand-service-tile.erb`
BROKER_TARFILE=`ls $RELEASE_DIR/on-demand-broker/*.tgz`

rm -rf $OUTPUT_DIR/tmp
mkdir -p $OUTPUT_DIR/tmp
pushd $OUTPUT_DIR/tmp
  mkdir -p metadata releases migrations/v1
  migrations_timestamp=`date +"%Y%m%d%H%M"`

  cp $TEMPLATES_DIR/*migration.js migrations/v1/${migrations_timestamp}_migration.js
  ruby $SCRIPT_DIR/generateYml.rb $PRODUCT_VERSION $SERVICE_BROKER_VERSION $SERVICE_ADAPTER_RELEASE_VERSION $SERVICE_RELEASE_VERSION $TILE_FILE_FULL_PATH > metadata/aerospike-on-demand-service-tile.yml
 
  cp $SERVICE_ADAPTER_DIR/dev_releases/aerospike-service-adapter-release/*.tgz releases/
  cp $SERVICE_RELEASE_DIR/dev_releases/aerospike-service-release/*.tgz releases/
  cp $BROKER_TARFILE releases/

  # Ignore bundling the stemcell as most often the Ops Mgr carries the stemcell.
  # If Ops Mgr complains of missing stemcell, change the version specified inside the tile to the one that Ops mgr knows about

  zip -r ${PRODUCT_NAME}-v${PRODUCT_VERSION}.pivotal metadata releases migrations
  mv ${PRODUCT_NAME}-v${PRODUCT_VERSION}.pivotal ..
popd
rm -rf $OUTPUT_DIR/tmp
echo "Created Tile:  $OUTPUT_DIR/${PRODUCT_NAME}-v${PRODUCT_VERSION}.pivotal "
echo ""