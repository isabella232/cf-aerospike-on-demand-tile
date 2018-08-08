#!/bin/bash
#set -exv

function realpath() {
      [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
ROOT_DIR=$SCRIPT_DIR/..
KILN_DIR=$ROOT_DIR/kiln-build

SERVICE_ADAPTER_DIR=$ROOT_DIR/cf-aerospike-service-adapter-release
SERVICE_RELEASE_DIR=$ROOT_DIR/cf-aerospike-service-release

rm $ROOT_DIR/*.pivotal

echo "Removing older versions"
rm $KILN_DIR/releases/*.tgz
rm $SERVICE_RELEASE_DIR/aerospike-service-release*.tgz
rm $SERVICE_ADAPTER_DIR/aerospike-service-adapter-release*.tgz

if [ ! -d "${SERVICE_ADAPTER_DIR}" ] ; then
  echo "ERROR:"
  echo "$SERVICE_ADAPTER_DIR not found."
  echo "Execute 'git submodule update --init' to initialize the submodules"
  exit -1
fi

# # Verify the on-demand-broker exists, and copy it to the release directory
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

cp on-demand-broker/*.tgz $KILN_DIR/releases

# # Verify the routing-release exists, and copy it to the release directory

pushd routing-release
  ROUTING_NAME=`find . -name *.tgz | awk -F"-" '{ print $1 }'`
popd

if [ -z "$ROUTING_NAME" ]; then
  echo "ERROR:"
  echo "routing not found."
  echo "Get the latest routing-release tgz from Pivotal and copy to the routing directory"
  exit -1
fi

cp routing-release/*.tgz $KILN_DIR/releases

if [ "$#" -gt 1 ]; then
  echo "Usage: [<version>]"
  echo " 1st arg (optional): version of the tile (i.e. 0.0.1)"
  echo ""
  echo " Check sample props files under ${SCRIPT_DIR}/templates folder for creating the input files"
  exit -1
fi

# # Read versions from service and service-adapter submodules
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
  echo "Creating the service-adapter release"
  ./scripts/createRelease.sh
popd
cp $SERVICE_ADAPTER_DIR/aerospike-service-adapter-release*.tgz kiln-build/releases

# Create the release for the service release
pushd $SERVICE_RELEASE_DIR
  echo "Creating the service release"
  ./scripts/createRelease.sh
popd
cp $SERVICE_RELEASE_DIR/aerospike-service-release*.tgz kiln-build/releases

pushd $KILN_DIR
  echo "Baking the tile"
  ./bake $PRODUCT_VERSION
popd

cp $KILN_DIR/*.pivotal $ROOT_DIR
echo "Finished building the tile"