# fabric-tools

This package is designed to support configuration and deployment of dovetail applications in public cloud services, including AWS, Azure, GCP, and IBM Cloud. Since [IBM Blockchain Platform (IBP)](https://cloud.ibm.com/catalog/services/blockchain-platform-20) was the first public cloud environment that supports Hyperledger Fabric v1.4, we describe the deployment process of the sample [marble](../samples/marble) for IBP only. TODO: This instruction requires update.

## Build and install fabric-tools

```bash
cd /path/to/dovetail-lab/fabric-cli/fabric-tools
go install
fabric-tools help
```

## Create Hyperledger Fabric network in IBM Cloud

The [IBP Tutorial](https://github.com/IBM/blockchainbean2) describes how to create a Hyperledger Fabric network in IBM Cloud, which involves the following steps:

1. Create IBM Cloud Kubernetes cluster, [IBP Tutorial (Step 4)](https://github.com/IBM/blockchainbean2#step-4-create-ibm-cloud-services);
2. Build Fabric network using IBM Blockchain Platform console, [IBP Tutorial (Step 5)](https://github.com/IBM/blockchainbean2#step-5-build-a-network), which includes:

- Create and start Certificate Authority (CA) servers for orderer and peer organizations;
- Create identities for organization administrators and peer/orderer nodes;
- Create MSP definitions for orderer and peer organizations;
- Create and start orderer and peer nodes;
- Define network consortium by adding organizations in an orderer;
- Create a channel, and join peers to the channel.

## Package and install/instantiate chaincode

Chaincode must be packaged as `cds` file to be installed in IBP. We can package the [marble_cc](https://github.com/dovetail-lab/fabric-samples/marble) chaincode as described in the sample.

You can then install and instantiate the resulting package, `marble_cc_1.0.cds` using the `IBP console` as shown in the [IBP Tutorial (Step 6)](https://github.com/IBM/blockchainbean2#step-6-deploy-blockchainbean2-smart-contract-on-the-network).

## Prepare IBP network for client app

Download the connection profile of the instantiated `marble_cc_1.0.cds` as shown in the [IBP Tutorial (Step 7)](https://github.com/IBM/blockchainbean2#step-7-connect-application-to-the-network). Save the profile in the `scripts` folder, e.g., [scripts/ibpConnection.json](./scripts/ibpConnection.json).

In IBP Console, register a user with type of `client` in `Org1 CA` as shown in the [IBP Tutorial (Step 5)](https://github.com/IBM/blockchainbean2#use-your-ca-to-register-identities). This user, e.g., `user1`, will be used by the [marble-client](https://github.com/dovetail-lab/fabric-samples/marble) to invoke the chaincode.

Execute the following script to create the network config and user crypto data for the client app:

```bash
cd /path/to/dovetail-lab/fabric-cli/fabric-tools/scripts
./setup-ibp.sh ibpConnection.json user1 user1pw
```

This script uses the connection profile and user and password specified in the above steps, so change them to match the names in your configuration.

Verify that a network-config-file, `config-ibp.yaml` is created, which will be used by the client app to connect to the IBP network. A folder `crypto-ibp` should be created and it contains required crypto data, especially the private key and signing certificate of the client user, `user1`, which is in the folder, e.g., `crypto-ibp/organizations/org1msp/users/user1/msp`, and the `signing certificate` should be named as, e.g., `signcerts/user1@org1msp-cert.pem`.

Note that the setup script depends on the [fabric-ca-client](https://github.com/hyperledger/fabric-ca), which must be installed in advance, i.e.,

```bash
go get -u github.com/hyperledger/fabric-ca/cmd/...
```

## Edit and build marble-client app

Use [TIBCO Flogo® Enterprise v2.10](https://docs.tibco.com/products/tibco-flogo-enterprise-2-10-0) to edit the [`marble-client.json`](https://github.com/dovetail-lab/fabric-samples/marble/marble-client.json):

- Start Flogo Enterprise

```bash
cd $FLOGO_HOME/2.10/bin
./start-webui.sh
```

- Launch Flogo Console in Chrome at `http://localhost:8090`
- Open `Extensions` tab, and upload `fabclient` extension, `fabclientExtension.zip` which can be built from [fabric-client](https://github.com/dovetail-lab/fabric-client);
- Open `Apps` tab, create app named `marbleeclient` and import app model file [`marbleeclient.json`](../samples/marble/marble_client.json);
- Open the `marble_client` and click the `App Properties` link, update the value of `CLIENT_USER` to match the name of the user created in the previous step;
- Open `Connections` tab, edit and save the connector `local-first-network` to use configuration files `./scripts/config-ibp.yaml`, which is generated in the previous step, and [empty_entity_matchers.yaml](../testdata/empty_entity_matchers.yaml);
- Open `Apps` tab, export the `marble_client` and download the updated app to [`samples/marble/marble_client.json`](https://github.com/dovetail-lab/fabric-samples/marble/marble-client.json).

Build and start the marble-client app:

```bash
cd /path/to/dovetail-lab/fabric-samples/marble
make build-client
export CRYPTO_PATH=/path/to/dovetail-lab/fabric-cli/fabric-tools/scripts/crypto-ibp
FLOGO_LOG_LEVEL=DEBUG FLOGO_SCHEMA_SUPPORT=true FLOGO_SCHEMA_VALIDATION=false /tmp/marble_client/marble_client/src/marble_client
```

Note that the `CRYPTO_PATH` must be set to the crypto folder generated by the previous step. To run the client app in a docker container, you can copy or mount this crypto folder in the docker container, and configure `CRYPTO_PATH` accordingly.

## Test marble-client

The REST APIs, described in the sample, [`marble`](../samples/marble#test-marble-rest-service-and-marble-chaincode), can be used to test the `marble-client` with the chaincode `marble_cc` instantiated in IBM Cloud.
