# README.md

```shell
docker run \
-v .:/myapp \
wubuku/dddappp:0.0.1 \
--dddmlDirectoryPath /myapp/dddml \
--boundedContextName Test.SuiInterfaceDemo \
--suiMoveProjectDirectoryPath /myapp/core \
--boundedContextSuiPackageName sui_intf_demo_core \
--boundedContextJavaPackageName org.test.suiinterfacedemo \
--javaProjectsDirectoryPath /myapp/sui-java-service \
--javaProjectNamePrefix suiinterfacedemo \
--pomGroupId test.suiinterfacedemo
```


## Some Tips

### Clean Up Exited Docker Containers

Run the command:

```shell
docker rm $(docker ps -aq --filter "ancestor=wubuku/dddappp:0.0.1")
```

### A More Complex Sui Demo

If you are interested, you can find a more complex Sui Demo here: ["A Sui Demo"](https://github.com/dddappp/A-Sui-Demo).
