# docker-ModeSMixer2

![ModeSMixer2 Logo](http://xdeco.org/wp-content/uploads/2014/11/logo_mm2-300x41.png "ModeSMixer2 Logo")

ModeSMixer2 is versatile console application for combining and rebroadcasting feeds with Mode-S data in a variety of formats.

ModeSMixer2 has ability to receive data via network from Mode-S decoder for RTLSDR devices as [readsb](https://hub.docker.com/r/mikenye/readsb), [dump1090](https://hub.docker.com/r/mikenye/piaware), rtl1090, modesdeco2, ADSB# or some other program producing and outputting Mode-S data over network.

For more info, see the project's website: <http://xdeco.org>.

## Multi Architecture Support

Currently, this image should pull and run on the following architectures:

* `amd64`: Linux x86-64
* `i386`: Linux x86 (32-bit)
* `arm32v7`, `armv7l`: ARMv7 32-bit (eg: Odroid HC1/HC2/XU4, RPi 2/3/4)
* `arm64v8`, `aarch64`: ARMv8 64-bit (eg: RPi 4)

## Up and Running - `docker run`

You can see all `modesmixer2` command line arguments with:

```
docker run --rm -it mikenye/modesmixer2:latest --help
```

You can then instantiate a container with the syntax:

```shell
docker run <docker_arguments> mikenye/modesmixer2:latest <modesmixer2_command_line_arguments>
```

Here is a basic example:

```shell
docker run \
  -d \
  --name mm2 \
  --restart=always \
  -it \
  -p 8081:8081 \
  mikenye/modesmixer2:latest \
    --inConnect=readsb:30005 \
    --metric \
    --web=8081
    --location=LAT:LONG
```

You can then hit the web interface at <http://dockerhost:8081>.

## Up and Running - `docker-compose`

Here is a sample `docker-compose.yml` file:

```yaml
version: '2.0'

networks:
  adsbnet:

services:

  modesmixer2:
    image: mikenye/modesmixer2:latest
    tty: true
    container_name: mm2
    restart: always
    depends_on:
      - readsb
    ports:
      - 8081:8081
    networks:
      - adsbnet
    command:
      - --inConnect=readsb:30005
      - --metric
      - --web=8081
      - --location=LAT:LONG
```

## Environment Variables

No container environment variables are currently supported.

## Ports

Ports should be opened as required by your `modesmixer2` command line arguments.

## Logging

All processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-ModeSMixer2/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
