## Aerospike On-Demand Service for Pivotal Cloud Foundry

This projecct packages up the cf-aerospike-service-adapter-release and the cf-aerospike-service-release into a Pivotal Tile which can be deployed into Pivotal Cloud Foundry.

### Prerequisites

1. [BOSH CLI](https://bosh.io/docs/bosh-cli.html)
2. [Kiln](https://github.com/pivotal-cf/kiln) 
3. Copy latest on-demand service SDK tgz file from [Pivotal](https://network.pivotal.io/products/on-demand-services-sdk/) to the on-demand-broker directory. If you get a 404 on that page, log into Pivotal first.
4. Download the routing release from the [GitHub Repo](https://github.com/cloudfoundry/routing-release) as a release. Add it to the ``routing-release`` directory
5. Run ``git submodule update --init`` to fetch the submodules
6. After updating the submodules, follow their Readme files to ensure that the correct blobs are in place.

### Build Instructions

~~~~
# An optional version may be provided, if omitted the value in scripts/product_version will be used
scripts/createTile.sh
~~~~
