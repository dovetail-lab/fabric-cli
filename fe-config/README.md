# fe-config

As of Flogo Enterprise 2.10, it does not support build with Go modules. This script here generates necessary files in a Flogo Enterprise installation, so it can support Go modules.

Execute the following script:

```bash
FE_HOME=/path/to/flogo/2.10
cd ./fe-config
./fe-pack.sh ${FE_HOME}
```

The result is a package `flogo.zip` with generated Go modules that can be used to build the `dovetail-tools` docker image as described in [scripts](../scripts).
