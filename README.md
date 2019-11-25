# liltaz/vsftpd

This Docker container implements a vsftpd server, with the following features:

 * Ubuntu base image.
 * vsftpd
 * Virtual users
 * Passive mode

### Installation from [Docker registry hub](https://registry.hub.docker.com/u/liltaz/vsftpd/).

You can download the image with the following command:

```bash
docker pull liltaz/vsftpd
```

Environment variables
----

This image uses environment variables to allow the configuration of some parameters at run time:

* Variable name: `FTP_USER`
* Default value: admin
* Accepted values: Any string. Avoid whitespaces and special chars.
* Description: Username for the default FTP account. `admin` will be used by default.

----

* Variable name: `FTP_PASS`
* Default value: `admin`
* Accepted values: Any string.

----

* Variable name: `FTP_ANON`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Enables / Disables Anonymous access

----

* Variable name: `PASV_ADDRESS_ENABLE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Enables / Disables Passive Mode

----


* Variable name: `PASV_ADDRESS_RESOLVE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to use a hostname (as opposed to IP address) in the `PASV_ADDRESS` option.

----

* Variable name: `PASV_ADDRESS`
* Default value: 127.0.0.1
* Accepted values: Any IPv4 address or Hostname (see PASV_ADDRESS_RESOLVE).

----

* Variable name: `PASV_ADDR_RESOLVE`
* Default value: NO.
* Accepted values: YES or NO.
* Description: Set to YES if you want to use a hostname (as opposed to IP address) in the PASV_ADDRESS option.

----

* Variable name: `PASV_ENABLE`
* Default value: YES.
* Accepted values: YES or NO.
* Description: Set to NO if you want to disallow the PASV method of obtaining a data connection.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 47400
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 47470.
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

Exposed ports and volumes
----

The image exposes ports `20` and `21`. Also, exports two volumes: `/home/vsftpd`, which contains users home directories, and `/var/log/vsftpd`, used to store logs.

When sharing a homes directory between the host and the container (`/home/vsftpd`) the owner user id and group id should be 14 and 80 respectively. This corresponds to ftp user and ftp group on the container, but may match something else on the host.

Use cases
----

1) Create a temporary container for testing purposes:

```bash
  docker run --rm liltaz/vsftpd
```

2) Create a container in active mode using the default user account, with a binded data directory:

```bash
docker run -d -p 21:21 -v /my/data/directory:/home/vsftpd --name vsftpd liltaz/vsftpd
# see logs for credentials:
docker logs vsftpd
```

3) Create a **production container** with a custom user account, binding a data directory and enabling both active and passive mode:

```bash
docker run -d -v /my/data/directory:/home/vsftpd \
-p 20:20 -p 21:21 -p 47400-47470:47400-47470\
-e FTP_USER=myuser -e FTP_PASS=mypass \
-e PASV_ADDRESS=127.0.0.1 -e PASV_MIN_PORT=47400 -e PASV_MAX_PORT=47470 \
--name vsftpd --restart=always liltaz/vsftpd
```

4) Manually add a new FTP user to an existing container:
```bash
docker exec -i -t vsftpd bash
mkdir /home/vsftpd/myuser
echo -e "myuser\nmypass" >> /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
exit
docker restart vsftpd
```