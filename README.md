# vowpalwabbit

VowpalWabbit https://vowpalwabbit.org/

## static VW binary

https://github.com/VowpalWabbit/vowpal_wabbit/wiki/Building

```shell
# build VW
make docker-build

# run the docker
make docker-run

# run the VW instance inside the docker container
vw --version
```

## extract the executable to the `target` folder

```shell
# extract executable from the docker container
make extract

# run the VW instance on the host machine
target/vw --version
```
