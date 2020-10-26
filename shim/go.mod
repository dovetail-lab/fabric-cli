module github.com/dovetail-lab/fabric-cli/shim

go 1.14

replace github.com/project-flogo/flow => github.com/yxuco/flow v1.1.1

replace github.com/project-flogo/core => github.com/yxuco/core v1.1.1

require (
	github.com/dovetail-lab/fabric-chaincode/common v1.0.0
	github.com/dovetail-lab/fabric-chaincode/trigger/transaction v1.0.0
	github.com/hyperledger/fabric v1.4.9
	github.com/project-flogo/core v1.1.0
)
