# FLAIR-in-a-Box Quick Start!
---

FLAIR-in-a-box (Fiab) is the easiest way for you to join the FLAIR-GG network!

It will automatically install all components required for full participation (even if you decide not to use them!)

There are two components - Metadata and Data.  Only the Metadata layer is required.  

To install the Metadata layer, cd into the "MetadataLayer" folder, and run the `install-sextans-sight.sh` installation script.  Answer the questions to set up your custom installation.  After that, you can then decide if you want to offer more than just a general description of your database.

To install the Data Layer:  .... TBD - this layer is beign rewritten at this time for additional security.



## CONTENTS

- [Installation requirements](#requirements)
- [Downloading](#downloading)
- [Installing from scratch](#installing)
- [Testing your installation](#testing)
- [Using your FLAIR-in-a-Box](#using)
- [Using your FLAIR-in-a-Box](#understanding)
- [Customizing your FLAIR-in-a-Box](#customizing)
- [Connecting to the FLAIR-GG Virtual Platform](#connecting)

<a name="requirements"></a>

## Requirements

To use the FLAIR-in-a-box solution you `must` meet the following requirements.

**User requirements (Person who is deploying this solution)**

- Basic knowledge about Docker​
- Basic GitHub knowledge​
- (optional) Awareness of the [FLAIR-GG semantic model](../../SemanticModel/) if you plan to create FAIR data from your Germplasm bank data

**System requirements​ (Machine where this solution is being deployed)**

- Docker engine ​
- Docker-compose application​

---

<a name="downloading"></a>

## Downloading

#### FAIR-in-a-box

To get the FAIR in a box code clone this repository to your machine.

```sh
git clone https://github.com/wilkinsonlab/FLAIR-GG
```

---



## Installing

<a name="installing"></a>

Once you have completed the "Downloading" section of this tutorial, you can run `install-sextans-sight.sh` in the `./FLAIR-in-a-box/MetadataLayer` folder

```
bash ./install-sextans-sight.sh
```

### How to answer the installation questions

If you are installing for testing purposes, you can simply use a localhost address and port.  In this case, the port in youir "permanent address (e.g. http://localhost:7070) should match the port that you answer for the FDP Port in the second question.

If you are installing for production, you will need a permanent address and have your web server set up to proxy your SSL to the Docker image.  You can regisger a permanent identifier using, for example, [W3ID](https://github.com/perma-id/w3id)).  You will be asked for that address, as well as ports for your FAIR Data Point, GraphDB, and a "installation prefix" - a label for all of your components (e.g. "myflair").  The FDP port is where your proxy should point to.

The installation prefix is simply a short-name for your database.  NO SPACES, and better as lower-case letters.  For example:
   - crampdb
   - euronmd
   - dpp
   - htad
   - crag
   - ACME  <---- this will be used for the rest of the tutorial

This prefix is used to isolate one installation of FLAIR-in-a-box from another, if you are hosting multiple FAIR data points on the same server.

After about a minute, the installer will send a message to the screen asking you to check that the installation was successful. This message will last for 10 minutes, giving you enough time to explore the links in the message. After 10 minutes, the services will all automatically shut down. You can stop the installer by `CTRL-C` at any time.

### Find the folder with your final server config... Ready-To-Go!

The installer will create a folder containing all of your server configuration files.  You can copy this folder anywhere on your system, e.g. to keep your servers all in one folder outside of your GitHub copy of FiaB.

The folder will be called "prefix-ready-to-go"  (e.g. "ACME-ready-to-go").  Inside that folder is a customized docker-compose file (docker-compose-ACME.yml) for your deployment.  So for example, you would issue the commands:

```

cp -r ACME-ready-to-go ~/SERVERS/
cd ~/SERVERS/ACME-ready-to-go
docker-compose -f docker-compose-ACME.yml up

```

Your FAIR Data Point is now running at whatever port you selected for the FDP (default 7070)


---
<a name="testing"></a>

## Testing your installation

- If the **GraphDB** deployment is successful then you can access GraphDB by visiting the following URL.

**Note:** If you deploy the `FLAIR in a box` solution in your laptop then check only for **local deployment** url.

| Service name | Local deployment                                | Production deployment |
| ------------ | ----------------------------------------------- | --------------------- |
| GraphDB      | [http://localhost:7200](http://localhost:7200/) | http://SERVER-IP:7200 |

By default the GraphDB service is secured so you need credentials to login to the graphDB. Please find the default graphDB's credentials in the table below.

| Username | Password |
| -------- | -------- |
| `admin`  | `root`   |

- If the **FAIR Data Point** deployment is successful then you can access the FAIR Data Point by visiting the following URL.

| Service name    | Local deployment                               | Production deployment |
| --------------- | ---------------------------------------------- | --------------------- |
| FAIR Data Point | [http://localhost:7070](http://localhost:7070) | http://SERVER-IP:7070 |

**Note:** If you deploy the `FLAIR in a box` solution in your laptop then check only for **local deployment** url.

In order to add content to the FAIR Data Point you need credentials with write access. Please find the default FAIR Data Point's credentials in the table below.

| Username                      | Password   |
| ----------------------------- | ---------- |
| `albert.einstein@example.com` | `password` |

---

<a name="using"></a>

# Using FLAIR-in-a-box for data transformation

## NOTE THAT THIS INFORMATION IS OUTDATED WHILE WE RECODE THE DATA LAYER - STAY TUNED!

NOTE: The folders "metadata" and "bootstrap" are no longer needed. ALL ACTIVITIES FROM NOW ON HAPPEN INSIDE OF THE ACME-ready-to-go FOLDER, and this folder can be moved anywhere on your system.

In the folder ./ACME-ready-to-go there is a docker-compose-ACME.yml file, and two directories.

the folder structure is:

```
.--
  | docker-compose-ACME.yml
  | /data
  ---
    | /triples

```

- The /data folder is where you will place your administrative, location, and germplasm CSV files [Here are the instructions for how to create these CSV files](../../SemanticModel/CSV/).
- The /data folder will also contain the [YARRRML Templates](../../SemanticModel/) that will be applied to the final CSV.
- *NOTA BENE*:  Please execute `chmod a+w ./data/triples` prior to executing a transformation.  The transformation tool in this container runs with very limited permissions, and cannot write to a folder that is mounted with default permissions.
- *NOTA BENE*:  The YARRRML templates contains a placeholder for your installation's base URI.  This is passed as an environment variable `baseURI`, which appears in the flair-box-daemon clause of your docker-compose-ACME.yml file:

```
  flair-box-daemon: 
    image: markw/flair-box-daemon:0.0.6
    container_name: flair-box-daemon
    environment:
      GraphDB_User: ${GraphDB_User}
      GraphDB_Pass: ${GraphDB_Pass}
 -->  baseURI: ${baseURI}
      GRAPHDB_REPONAME: ${GRAPHDB_REPONAME}
```

If you set baseURI to be "http://my.domain.org/"   then all 'local' URLs in your resulting transformed data will use that as their prefix.  YOU CANNOT DO DATA TRANSFORMATIONS UNTIL THAT ENVIRONMENT VARIABLE IS SET!

#### Preparing input data

The FLAIR-in-a-box Transformation process has two steps:

1) CSV file(s) are created by the data owner (`you must do this!`)
2) By calling the "RDFization Trigger" port, Each CSV file is processed by its associated YARRRML template, and RDF is output into the `./data/triples` folder
  

*NOTA BENE* the filenames MUST NOT BE CHANGED!  The files are called `administrative.csv`, and `administrative_yarrrml.pre-yaml` (and similarly for "germplasm" and "location"!!  YOU CANNOT CHANGE THESE NAMES!  **If you do not wish to expose certain types of data (e.g. if collection location is sensitive) you simply do not provide the CSV file for location.**

#### Configuring configuration and data folders

**Step 1:** Folder structure

Make sure the following folder structure, relative to where you plan to keep your pre and post-transformed data, is available:

```
        ./ACME-ready-to-go/data/
        ./ACME-ready-to-go/data/administrative.csv
        ./ACME-ready-to-go/data/location.csv
        ./ACME-ready-to-go/data/germplasm.csv
        ./ACME-ready-to-go/data/administrative_yarrrml.pre-yaml
        ./ACME-ready-to-go/data/location_yarrrml.pre-yaml
        ./ACME-ready-to-go/data/germplasm_yarrrml.pre-yaml
        ./ACME-ready-to-go/data/triples   (Remember to `chmod a+w` this folder!)
```

**Step 2:** Edit the .env file

the .env file will create the values for the environment variables in the docker-compose file. The first of these `baseURI` is the base for all URLs that represent your transformed data. This should be set to something like:

`http://my.database.org/my_germplasm_data/`

this will result in a Triple that looks like this:

`<http://my.database.org/my_rd_data/sample_123345_asdssaewe#ID> <sio:has-value> <"123345">`

optimally, these URLs will resolve... but this is your responsibility - we cannot automate this.


**Step 3:** Input CSV files

Put appropriately generated CSV files into the `ACME-ready-to-go/data`. 

If you are unsure which columns to fill for each data type, see the [glossary](../../SemanticModel/CSV/)


**Step 4:** Input YARRRML templates

The `YARRRML` template is standardized


**Step 5:** Executing transformations

Call the url: http://localhost:4567/administrative (or whatever 'trigger' port number you selected when you answered the installation questions) to trigger the transformation of each CSV file; the URL above would trigger transformation of the administrative.csv data, and the same holds for 'germplasm' and 'location'.  The resulting RDF will be auto-loaded into graphDB (*NOTA BENE* this will over-write what is currrently loaded!  i.e. the FLAIR-in-a-Box pipeline can only be used to take snapshots, NOT incremental updates!)


<a name="understanding"></a>

# Understanding your FLAIR in a box installation

## Software used in FLAIR in a box

**Triple store:**
To store the `rdf` documents generated by the `FLAIR in a box` solution we need to have a triplestore that stores these documents. In the `FLAIR in a box` solution we use the free version of [GraphDB](https://graphdb.ontotext.com) as a triplestore.

**FAIR Data Point:**
To describe the content of your resource we need a `metadata provider` component. For the `FLAIR in a box` solution we use `FAIR Data Point` software that provides a description (metadata) of your resource. To learn more about the FAIR Data Point please visit this [link](https://fairdatapoint.readthedocs.io/en/latest/)

**RDFization:**
FLAIR-GG has created a customized version of the yarrrml-rmlmapper docker image from [RMLio](https://github.com/RMLio/yarrrml-rmlmapper-docker).  This allows rmlmapper to run as a server that takes arguments.


# Customization of your installation
<a name="customizing"></a>

## Update username and password for the GraphDB

- Go to http://localhost:7200 (or wherever you set the GraphDB port) and login with the default username and password ("admin"/"root").
- Enter the "settings" for the admin account, and update the password. Note that this account will have access to both the metadata and the data (!!) so make the password strong!
- at the terminal, shut down the system (docker-compose down)
- go to the ./ACME-ready-to-go/fdp folder and edit the file "application-ACME.yml"
- in the repository settings, update the username and password to whatever you selected above
- now go back to the ACME-ready-to-go folder and bring the system back up. Your FDP database is now protected with the new password.


## Create a "safe" users for the administrative, location, and germplasm databases

- Go to http://localhost:7200 (or whatever you set the GraphDB port to during installation) and login with the administrator username and password
- Enter the "settings" and "users".
- Create a new user and password, giving them read/write permission ONLY on the FDP database, and read-only permission on all other databases.
- in the FAIR-ready-to-go folder, update the `.env` file with this new limited-permissions user
- docker-compose down and up to restart the server
- Consider closing the GraphDB external port in the docker-compose, or limiting it to localhost... there's no need for GraphDB to be exposed!


## Update the colors and logo

- go to the `ACME-ready-to-go/fdp` folder
- add your preferred logo file into the ./assets subfolder
- edit the ./variables.scss to point to that new logo file, and select its display size (or keep the default)
- to change the default colors, edit the first two lines to select the primary and secondary colors (the horizontal bar on the default http://localhost:7070 homepage shows the primary color on the left and the secondary color on the right)
- if you have a preferred favicon, replace the one in that folder with your preferred one.
- now go back to the ACME-ready-to-go folder and bring the docker-compose back up. Your FDP client will now be customized with your preferred icons and colors


<a name="connecting"></a>

## Connect to the FLAIR-GG Virtual Platform

__Full instructions for modifying your default FLAIR-in-a-box to match the requirements for the FLAIR-GG Virtual Platform [can be found here](../../FDP-Configuration/)__  

To connect to the [FLAIR-GG Virtual Platform](https://vp.bgv.cbgp.upm.es), you first need to register yourself in the [VP Index](https://index.bgv.cbgp.upm.es), which is accomplished by adding the indexer "ping" function to your FAIR Data Point.  To do this:

- Login to your FDP via the Web page
- Go to "settings"
- About halfway down the settings there is a "Ping" section.  Add the following URL to the "Ping":
    - https://index.bgv.cbgp.upm.es/

Once you have done this, your site will be indexed in the VP Index on the next "ping" cycle (should be weekly, by default).  THE INDEX WILL LOOK FOR THE "VPDiscoverable" tag in the vpConnection property of whatever resource(s) you want to be indexed by the platform.  e.g. if you have 5 datasets, but you only want 3 of them to be indexed by the VP, then you set the vpConnection property to "VPDiscoverable" for ONLY those three datasets (the others have no value for that property). In the metadata editor of the FDP web page, this is done via a dropdown menu.

If you want to force re-indexing, you can shut-down (docker-compose down) and restart your FDP.  Alternatively, you can force a re-indexing by making the following `curl` command:

```
curl -X POST https://index.bgv.cbgp.upm.es/ -H "Content-Type: application/json" -d
{"clientUrl": "https://my.fdp.address.here/}
```

