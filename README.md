## Aerospike On-Demand Service for Pivotal Cloud Foundry

This projecct packages up the cf-aerospike-service-adapter-release and the cf-aerospike-service-release into a Pivotal Tile which can be deployed into Pivotal Cloud Foundry.

### Prerequisites

1. [BOSH CLI](https://bosh.io/docs/bosh-cli.html)

2. Copy latest on-demand service SDK tgz file from [Pivotal](https://network.pivotal.io/products/on-demand-services-sdk/) to the on-demand-broker directory. If you get a 404 on that page, log into Pivotal first.

### Build Instructions

~~~~
git submodule update --init
scripts/createTile.sh
~~~~
