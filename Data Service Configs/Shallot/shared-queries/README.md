# Queries for the FLAIR-GG Virtual Platform

## IUCN endangerment categories
Query : [IUCN categories](./IUCN_categories.rq)
Extracts the World Flora Online scientific names for all accessions that have the [IUCN Red List categories](https://www.iucnredlist.org/) <code>Vulnerable, Endangered and Critically endangered</code>




# Installing Shallot for your site

1) create a folder /shallot/ in the folder were you currently run the fdp docker-compose
2) cd /shallot
3) create the docker-compose.yml

```
services:
  shallot:
    image: markw/shallot:0.0.2
    hostname: "shallot"
    restart: always
    volumes:
    - ./shared-queries/:/home/grlc/queries/
    - ./config.ini:/home/grlc/grlc/config.default.ini
    ports:
     - "8088:80"   # pick your port here
    networks:
      - default
    environment:
      - DEBUG=true
      - GRLC_SPARQL_ENDPOINT=http://graphdb:7200/repositories/XXXXX  # XXXX is the name of your graphdb germplasm repository

networks:
  default:  # need to look this up in every case, to get on the same network as graphdb
    name: dpp4-ready-to-go_dpp4-default  # you need to look this up - it is the network that graphdb is on
    external: true

```
4) create the `config.ini` file in that folder:

```
[auth]
# DO NOT SET THIS!!!!   It is a security risk!  Leave it as xxx
github_access_token = xxx

[local]
# don't touch this
local_sparql_dir = /home/grlc/queries/

[defaults]
# Default endpoint, if none specified elsewhere
# this will be changed by the environment variable passed-in from Docker compose
sparql_endpoint = http://dbpedia.org/sparql
server_name = grlc.io
# endpoint default authentication
# you need to login to GraphDB and make this a **readonly** user on the germplasm database

user = yourusername # for the germplasm database
password = yourpassword

# Logging level
debug = True

```
5) copy the /shared-queries/ folder into your /shallot/ folder
6) docker-compose up -d


you can test your installation from the command-line with:

curl localhost:8088/api-local/swagger

(or whatever port you chose to run shallot in the docker-compose)

7) you may need to edit your ssh proxy.  You need to configure the proxy to capture two URL paths:

`api-local`  and `static`

for Lighttpd it looks something like this:

```
$HTTP["host"] == "fdp.bgv.cbgp.upm.es" {
  $HTTP["url"] =~ "^/api-local(.*)$" {
        proxy.server  = ("" => (
            ("host" => "127.0.0.1", "port" => 8088)
        ))
  }
  $HTTP["url"] =~ "^/static(.*)$" {
        proxy.server  = ("" => (
            ("host" => "127.0.0.1", "port" =>8088)
        ))
  }
}

```

8) now you need to create Data Services in your FAIR Data Point, so that the Shallot services are discoverable!




