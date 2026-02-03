# OpenClinica

## How to get OpenClinica running under docker.

### 1 Create the user network and a volume for the OpenClinica Database and OpenClinica Data

```
docker network create --driver bridge oc-net
docker volume create oc-db-data
docker volume create oc-data
```

### 2 Get Postgres running

We make it save its data in the oc-db-data volume.

Must be postgres 9.5

```

docker run --name=oc-db -d -v oc-db-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=MASTER_PG_PASSWORD_CHANGE_ME_3141 --network oc-net postgres:9.5

podman pod create --name oc

podman run --name=oc-db -d -v oc-db-data:/var/lib/postgresql/data --pod oc -e POSTGRES_PASSWORD=MASTER_PG_PASSWORD_CHANGE_ME_3141 postgres:9.5
```

### 3 Create OpenClinica Database
This makes the database for openclinica and sets a password

```
docker exec oc-db su postgres -c $'psql -c "CREATE ROLE clinica LOGIN ENCRYPTED PASSWORD \'OC_DB_PASSWORD_CHANGE_ME\' SUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE" && psql -c "CREATE DATABASE openclinica WITH ENCODING=\'UTF8\' OWNER=clinica" && echo "host all  clinica    0.0.0.0/0  md5" >> $PGDATA/pg_hba.conf && /usr/lib/postgresql/$PG_MAJOR/bin/pg_ctl reload -D $PGDATA'

podman exec oc-db su postgres -c $'psql -c "CREATE ROLE clinica LOGIN ENCRYPTED PASSWORD \'OC_DB_PASSWORD_CHANGE_ME\' SUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE" && psql -c "CREATE DATABASE openclinica WITH ENCODING=\'UTF8\' OWNER=clinica" && echo "host all  clinica    0.0.0.0/0  md5" >> $PGDATA/pg_hba.conf && /usr/lib/postgresql/$PG_MAJOR/bin/pg_ctl reload -D $PGDATA'
```

### 4 Get the OpenClinica docker

```
git clone https://github.com/mshunshin/openclinica-docker.git
```

### 5 Fix the configuration files

The default files are located in ./openclinica.config  with a .new suffix.
Copy them, then edit the passwords and settings

```
cp ./openclinica.config/tomcat-users.xml.new ./openclinica.config/tomcat-users.xml
cp ./openclinica.config/datainfo.properties.new ./openclinica.config/datainfo.properties
cp ./openclinica.config/logging.properties.new ./openclinica.config/logging.properties

```

tomcat-users.xml -> change the password (all roles are removed anyway).

```
    vi ./openclinica.config/tomcat-users.xml

<tomcat-users>
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-jmx"/>
<role rolename="admin-gui"/>
<role rolename="admin-script"/>
<user username="admin" password="TOMCAT_ADMIN_PASSWORD_CHANGE_ME" roles=""/>
</tomcat-users>
```

datainfo.properties -> Change the database connection settings.

```
vi ./openclinica.config/datainfo.properties


dbType=postgres
dbUser=clinica
dbPass=OC_DB_PASSWORD_CHANGE_ME
db=openclinica
dbPort=5432
dbHost=oc-db


etc.
```

logging.properties -> No need to change anything here unless you want to change the log level.

```
vi ./openclinica.config/logging.properties

org.apache.catalina.core.ContainerBase.[Catalina].level = INFO
org.apache.catalina.core.ContainerBase.[Catalina].handlers = java.util.logging.ConsoleHandler

```

### 6 Build the OpenClinica Container

You must be in the openclinica directory.

```
cd openclinica
docker build -t oc .
```

### 7 Run the OpenClinica Container


```
docker run --name=oc -d -v oc-data:/usr/local/tomcat/openclinica.data -p 8080:8080 --network oc-net oc

podman run --name=oc-web -d -v oc-data:/usr/local/tomcat/openclinica.data --pod oc oc
```

### 7 Access Openclinica

Goto http://ip_address:81/OpenClinica


## Tips for fixing things

### I need to change the clinica database password in postgres (i.e. the link between openclinica and postgres)

Get the container id for postgres

```
docker container ls
```

Then get a shell in it.

```
docker exec -it container_id bash
```

Change to the postgres user (sudo is not installed, so use su) and run psql

```
su postgres
psql
```

Then fix the password

```
ALTER User clinica WITH ENCRYPTED PASSWORD 'NEW_PASSWORD';
\q
```
### I need to change the root openclinica password because I forgot it / locked myself out / it has expired

Link from: https://en.wikibooks.org/wiki/OpenClinica_User_Manual/ResetRootPassword

```
Resetting root's password
When you do not have the password of root anymore and you still want to access OpenClinca you can reset it to 12345678.

You do this by connecting to the study database (e.g. the database openclinica rather than postgres), either by using the psql-commandline-utility or by pgAdmin. You can issue the next command either as user postgres or as user clinica.

Log into postgres as the clincia account
su postgres
psql clinica

For OpenClinica 3.1 and later:

UPDATE user_account
SET passwd='7c222fb2927d828af22f592134e8932480637c0d',
status_id=1,
lock_counter=0
WHERE user_name='root';
For OpenClinica 3.0 and possibly earlier:

UPDATE user_account
SET passwd='7c222fb2927d828af22f592134e8932480637c0d',
account_non_locked=TRUE,
lock_counter=0
WHERE user_name='root';
This command not only resets the password (to 12345678, passwd is set to the SHA1 hashed value of 12345678: '7c222fb2927d828af22f592134e8932480637c0d'), but also resets the counter of failed logins to 0 and unlocks the account).
```


 tar -xvzf /home/matthew/2020-04-14_022447.oc-data.tar.gz -C /var/lib/containers/storage/volumes/
