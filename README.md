# mikenye/modesmixer2

![ModeSMixer2 Logo](http://xdeco.org/wp-content/uploads/2014/11/logo_mm2-300x41.png "ModeSMixer2 Logo")

ModeSMixer2 is versatile console application for combining and rebroadcasting feeds with Mode-S data in a variety of formats.

ModeSMixer2 has ability to receive data via network from Mode-S decoder for RTLSDR devices as [readsb](https://hub.docker.com/r/mikenye/readsb), [dump1090](https://hub.docker.com/r/mikenye/piaware), rtl1090, modesdeco2, ADSB# or some other program producing and outputting Mode-S data over network.

For more info, see the project's website: <http://xdeco.org>.

## Recent behaviour changing updates

If you are a first-time user of this container, skip this section.

As-per 13th February 2021, the image now uses environment variables to control the behaviour of ModeSMixer2. If you need the "old" behaviour, simply set the container's entrypoint to `/usr/local/bin/modesmixer2`. Examples follow.

### "Old" Container Behaviour - `docker run`

```
docker run \
  -d \
  --name mm2 \
  --restart=always \
  -it \
  -p 8081:8081 \
  --entrypoint /usr/local/bin/modesmixer2 \
  mikenye/modesmixer2:latest \
    --inConnect=readsb:30005 \
    --metric \
    --web=8081 \
    --location=LAT:LONG
```

### "Old" Container Behaviour - `docker-compose`

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
    entrypoint: /usr/local/bin/modesmixer2
    command:
      - --inConnect=readsb:30005
      - --metric
      - --web=8081
      - --location=LAT:LONG
```

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
  -e MM2_INCONNECT=readsb:30005 \
  -e MM2_METRIC=true \
  -e MM2_WEB=8081 \
  -e MM2_LOCATION=LAT:LONG
  mikenye/modesmixer2:latest \
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
    environment:
      - MM2_INCONNECT=readsb:30005
      - MM2_METRIC=true
      - MM2_WEB=8081
      - MM2_LOCATION=LAT:LONG
```

## Environment Variables

### Container Options

| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Local timezone in ["TZ database name" format](<https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>). | `UTC` |

### ModeSMixer2 Options

The following options control ModeSMixer2's Program options, which are documented at: <http://xdeco.org/?page_id=48>.

| Environment Variable | Controls ModesMixer2 Argument | Notes |
|-----|-----|-----|
| `MM2_INCONNECT` | `--inConnect` | Separate multiple values with `;`.<br />For example: `MM2_INCONNECT=192.168.1.10:30005;192.168.1.20:30001`<br />...would be identical to:<br />`--inConnect 192.168.1.10:30005 --inConnect 192.168.1.20:30001` |
| `MM2_INCONNECTID` | `--inConnectId` | Separate multiple values with `;`.<br />For example: `MM2_INCONNECTID=192.168.1.10:30005:MLAT1;192.168.1.20:30001:MLAT2`<br />...would be identical to:<br />`--inConnectId 192.168.1.10:30005:MLAT1 --inConnectId 192.168.1.20:30001:MLAT2` |
| `MM2_INSERVER` | `--inServer` | Separate multiple values with `;`.<br />For example: `MM2_INSERVER=30002;30003`<br />...would be identical to:<br />`--inServer 30002 --inServer 30003` |
| `MM2_INSERVERID` | `--inServerId` | Separate multiple values with `;`.<br />For example: `MM2_INSERVERID=31004:MLAT;31005:KJFK`<br />...would be identical to:<br />`--inServerId 31004:MLAT --inServerId 31005:KJFK` |
| `MM2_INSERVERUDP` | `--inServerUdp` | Separate multiple values with `;`.<br />For example: `MM2_INSERVERUDP=9742;9743`<br />...would be identical to:<br />`--inServerUdp 9742 --inServerUdp 9743` |
| `MM2_INSERIAL` | `--inSerial` | Separate multiple values with `;`.<br />For example: `MM2_INSERIAL=/dev/ttyUSB0:115200:hardware;/dev/ttyUSB1:9600:none`<br />...would be identical to:<br />`--inSerial /dev/ttyUSB0:115200:hardware --inSerial /dev/ttyUSB1:9600:none` |
| `MM2_OUTCONNECT` | `--outConnect` | Separate multiple values with `;`.<br />For example: `MM2_OUTCONNECT=beast:192.168.1.20:10003;msg:192.168.1.20:30013`<br />...would be identical to:<br />`--outConnect beast:192.168.1.20:10003 --outConnect msg:192.168.1.20:30013` |
| `MM2_OUTCONNECTID` | `--outConnectId` | Separate multiple values with `;`.<br />For example: `MM2_OUTCONNECTID=192.168.1.100:8888:UUDD:12.3456:-45.6789:20;192.168.1.200:8888:AABB:12.3456:-45.6789:30`<br />...would be identical to:<br />`--outConnectId 192.168.1.100:8888:UUDD:12.3456:-45.6789:20 --outConnectId 192.168.1.200:8888:AABB:12.3456:-45.6789:30` |
| `MM2_OUTCONNECTUDP` | `--outConnectUdp` | Separate multiple values with `;`.<br />For example: `MM2_OUTCONNECTUDP=avr:192.168.1.20:4756;beast:192.168.1.30:30004`<br />...would be identical to:<br />`--outConnectUdp avr:192.168.1.20:4756 --outConnectUdp beast:192.168.1.30:30004` |
| `MM2_OUTSERVER` | `--outServer` | Separate multiple values with `;`.<br />For example: `MM2_OUTSERVER=msg:30003;sbs10001:10001`<br />...would be identical to:<br />`--outServer msg:30003 --outServer sbs10001:10001` |
| `MM2_GLOBES` | `--globes` | |
| `MM2_WEB` | `--web` | |
| `MM2_WEB_AUTH` | `--web-auth` | |
| `MM2_DISABLE_WEB_LOG` | `--disable-web-log` | Set to any value to apply the `--disable-web-log` argument to ModeSMixer2 |
| `MM2_SILHOUETTES` | `--silhouettes` | |
| `MM2_PICTURES` | `--pictures` | |
| `MM2_DB` | `--db` | |
| `MM2_FRDB` | `--frdb` | |
| `MM2_LOCATION` | `--location` | |
| `MM2_ADD_REFERENCE_POINT` | `--add-reference-point` | |
| `MM2_ADD_POINTS` | `--add-points` | Separate multiple values with `;`.<br />For example: `MM2_ADD_POINTS=54.2882:88.0451:LOM;54.4557:89.3456:LMM`<br />...would be identical to:<br />`--add-points 54.2882:88.0451:LOM 54.4557:89.3456:LMM` |
| `MM2_LOCALTIME` | `--localtime` | Set to any value to apply the `--localtime` argument to ModeSMixer2 |
| `MM2_FILTER_EXPIRE` | `--filter-expire` | |
| `MM2_FILTER_COUNT` | `--filter-count` | |
| `MM2_FILTER_TIME` | `--filter-time` | |
| `MM2_FILTER_NOCOUNTRY` | `--filter-nocountry` | Set to any value to apply the `--filter-nocountry` argument to ModeSMixer2 |
| `MM2_FILTER_IC` | `--filter-ic` | Set to any value to apply the `--filter-ic` argument to ModeSMixer2 |
| `MM2_FLIGHT_EXPIRE_TIME` | `--flight-expire-time` | |
| `MM2_LOG_NOCONSOLE` | `--log-noconsole` | Set to any value to apply the `--log-noconsole` argument to ModeSMixer2 |
| `MM2_LOG_FILE` | `--log-file` | |
| `MM2_LOG_LEVEL` | `--log-level` | |
| `MM2_METRIC` | `--metric` | Set to any value to apply the `--metric` argument to ModeSMixer2 |

## Ports

Ports should be opened as required by your `modesmixer2` environment variables.

## Logging

Unless `MM2_LOG_NOCONSOLE` is set, all processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-ModeSMixer2/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
