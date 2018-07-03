## To build the tile:

### Prerequisites

1. [Kiln](https://github.com/pivotal-cf/kiln) 
2. First copy the `aerospike-service-adapter-release*.tgz` `aerospike-service-release*.tgz` and `on-demand-service-broker-0.21.2.tgz` into the release directory. The service adapter release may be found at: https://network.pivotal.io/products/on-demand-services-sdk/ . It is necessary to log in to download the file. Alternatively it may be found at the github repository for the project as a release
3. Download the routing release from the [GitHub Repo](https://github.com/cloudfoundry/routing-release) as a release


### Build Instructions
1. Ensure that the kiln-build/version file is equal to the current version of the tile, (1 less than the version to be released).
2.  Run `bake_metadata` and write it to .yml file to see the generated tile metadata.
3. If it looks alright, run `./bake` to write out the tile to a file `named aerospike-on-demand-$VERSION.pivotal` . This is the tile which can be uploaded into opsmanager.