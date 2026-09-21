# FLAIR-in-a-Box Quick Start!
---

FLAIR-in-a-Box is the easiest way for you to join the FLAIR-GG network!

FLAIR-in-a-Box is built on the [Sextans Suite](https://github.com/wilkinsonlab/Sextans-Suite), a general-purpose,
security-hardened installer for FAIR data servers. There is nothing FLAIR-specific to install: you install the
standard Sextans components and, for the data component, choose the **FLAIR-GG** data model.

There are two components - Metadata and Data.  **Only the Metadata component (Sextans Sight) is required.**

| Component | Sextans name | What it does | Required? |
| --- | --- | --- | --- |
| Metadata | **Sextans Sight** | A FAIR Data Point (plus its database) that describes your collection. This is what the FLAIR-GG Virtual Platform indexes. | Yes |
| Data | **Sextans Fix** | Transforms your germplasm CSV files into RDF using the FLAIR-GG semantic model and stores it in a private triple store. | Only if you want to offer more than a general description of your database |

## CONTENTS

- [Requirements](#requirements)
- [Downloading](#downloading)
- [Installing the Metadata component (Sextans Sight)](#sight)
- [Installing the Data component (Sextans Fix with the FLAIR-GG model)](#fix)
- [Preparing and transforming your data](#using)
- [Connecting to the FLAIR-GG Virtual Platform](#connecting)
- [Customizing your installation](#customizing)

<a name="requirements"></a>

## Requirements

**User requirements (person who is deploying this solution)**

- Basic knowledge about Docker
- Basic GitHub knowledge
- (optional) Awareness of the [FLAIR-GG semantic model](../SemanticModel/) if you plan to create FAIR data from your germplasm bank data

**System requirements (machine where this solution is being deployed)**

- Docker engine
- Docker-compose application

---

<a name="downloading"></a>

## Downloading

Clone the Sextans Suite repository to your machine.

```sh
git clone https://github.com/wilkinsonlab/Sextans-Suite.git
```

---

<a name="sight"></a>

## Installing the Metadata component (Sextans Sight)

```sh
cd Sextans-Suite/Sextans/Sight-install
bash ./install-sextans-sight.sh
```

The installer asks a few questions (an installation prefix, your permanent address, ports, and a password for
the database). **The [Sextans Sight documentation](https://github.com/wilkinsonlab/Sextans-Suite/tree/main/Sextans/Sight-install)
explains each question, the folder the installer creates, how to start it, how to secure it, and how to
brand it** - please read it, it is short.

Some notes that are specific to FLAIR-GG:

- If you are only testing, use a `localhost` address and port. Everything will work, but you cannot register a
  `localhost` server with the VP Index.
- For production you need a permanent address (for example a [W3ID](https://github.com/perma-id/w3id) redirect)
  and a web server that proxies your SSL to the FAIR Data Point port you chose.
- The installation prefix is a short name for your database. NO SPACES, and better as lower-case letters (e.g.
  `crampdb`, `euronmd`, `dpp`, `htad`, `crag`, `ACME`). We use **ACME** in the examples below.
- **Change the default FAIR Data Point administrator account immediately** (see the Sight documentation). If you
  don't, you will be locked out.
- Sextans Sight ships with configuration for the ERDERA project. **For FLAIR-GG, configure your FAIR Data Point
  using the schemas and instructions in [FDP-Configuration](../FDP-Configuration/)** instead.

---

<a name="fix"></a>

## Installing the Data component (Sextans Fix with the FLAIR-GG model)

Skip this section if you only want to publish a general description of your database.

```sh
cd Sextans-Suite/Sextans/Fix-install
bash ./install-sextans-fix.sh
```

When the installer asks **"CARE-SM-2 or FLAIR-GG?"**, answer **FLAIR-GG**. (You can skip the question by running
`DATA_MODEL=FLAIR-GG bash ./install-sextans-fix.sh`.)

Your data is stored in a private triple store (Virtuoso) that is **not** exposed to the internet, and its
anonymous SPARQL access is switched off. The
[Sextans Fix documentation](https://github.com/wilkinsonlab/Sextans-Suite/tree/main/Sextans/Fix-install) describes
the installer questions (a prefix, the trigger port, and the database password), how to run the server, and how to
query your data.

**Before you transform any data, set your base URI.** Open the `.env` file in the `ACME-Sextans-Fix` folder the
installer created and change this line to the base for all URLs that will identify your data:

```
baseURI=http://my.domain.org/data/
```

Every record in your transformed data is given a URL that starts with this value, so it should be an address
that you control (ideally one that will resolve). The installer only puts a placeholder here, and
**does not ask you for it**.

---

<a name="using"></a>

## Preparing and transforming your data

The transformation has two steps:

1. **You create the CSV file(s)** from your own database. This is the one step only you can do.
2. **You trigger the transformation.** Each CSV is mapped to RDF by the FLAIR-GG mapping for that file, and the
   result is loaded into your triple store.

#### Step 1: Create your CSV files

There are three files, and **their names are fixed**:

| File | Contains | Column definitions |
| --- | --- | --- |
| `admin.csv` | Who collected the material, who holds it, and the collection | [Administrative model](../SemanticModel/CSV/#administrative-model) |
| `germplasm.csv` | Species, taxon, phenotype, threat status, etc. | [Germplasm model](../SemanticModel/CSV/#germplasm-model) |
| `location.csv` | The site of collection | [Location model](../SemanticModel/CSV/#location-model) |

**If you do not wish to expose certain types of data (e.g. if collection location is sensitive) simply do not
provide that CSV file.** A type with no CSV file is not published.

The [column definitions and example files](../SemanticModel/CSV/) describe every column. In particular, **dates
must be ISO 8601 (`2024-01-01`, not `2024/01/01`)**.

Place the files in the `data` folder of your Fix installation (`Sextans-Fix/data/`, inside the
`ACME-Sextans-Fix` folder the installer created).

You do **not** need to supply the YARRRML mapping templates. The transformation service fetches the current
FLAIR-GG mappings itself, and fills in your base URI, so that all 'local' URLs in your data use your own
domain (for example `http://my.domain.org/`).

#### Step 2: Trigger the transformation

Request the trigger port you chose during installation (no parameters are needed or accepted):

```sh
curl http://localhost:<trigger-port>/
```

The daemon maps each CSV and loads the result into your triple store.

- Each run **replaces** what was loaded before: FLAIR-in-a-Box takes snapshots, it does not make incremental
  updates. Removing a CSV file and triggering again removes that type's data.
- **Your data must be valid.** If the transformation produces invalid RDF (the usual cause is a date that is not
  ISO 8601), the daemon stops with an error that lists the offending values. **Nothing is cleared or uploaded**, so
  your existing data is untouched: correct your export and trigger again.

#### Looking at your data

Virtuoso's anonymous SPARQL access is disabled on purpose, so Virtuoso Conductor's SPARQL box will show no
results even though your data is there. Query it with `/sparql-auth`, ISQL, or `curl --digest` as described in
the Sextans documentation.

---

<a name="connecting"></a>

## Connecting to the FLAIR-GG Virtual Platform

__Full instructions for configuring your FAIR Data Point to match the requirements of the FLAIR-GG Virtual Platform [can be found here](../FDP-Configuration/)__

To connect to the [FLAIR-GG Virtual Platform](https://vp.bgv.cbgp.upm.es), you first need to register yourself in the [VP Index](https://index.bgv.cbgp.upm.es), which is accomplished by adding the indexer "ping" function to your FAIR Data Point.  To do this:

- Login to your FDP via the Web page
- Go to "settings"
- About halfway down the settings there is a "Ping" section.  Add the following URL to the "Ping":
    - https://index.bgv.cbgp.upm.es/

Once you have done this, your site will be indexed in the VP Index on the next "ping" cycle (should be weekly, by default).  THE INDEX WILL LOOK FOR THE "VPDiscoverable" tag in the vpConnection property of whatever resource(s) you want to be indexed by the platform.  e.g. if you have 5 datasets, but you only want 3 of them to be indexed by the VP, then you set the vpConnection property to "VPDiscoverable" for ONLY those three datasets (the others have no value for that property). In the metadata editor of the FDP web page, this is done via a dropdown menu.

If you want to force re-indexing, you can shut-down (docker-compose down) and restart your FDP.  Alternatively, you can force a re-indexing by making the following `curl` command:

```
curl -X POST https://index.bgv.cbgp.upm.es/ -H "Content-Type: application/json" -d '{"clientUrl": "https://my.fdp.address.here/"}'
```

---

<a name="customizing"></a>

## Customizing your installation

Passwords, securing the ports, and changing the colors and logo of your FAIR Data Point are all part of standard
Sextans, and are documented in the
[Sextans Sight](https://github.com/wilkinsonlab/Sextans-Suite/tree/main/Sextans/Sight-install) and
[Sextans Fix](https://github.com/wilkinsonlab/Sextans-Suite/tree/main/Sextans/Fix-install) documentation.

## Existing FLAIR-in-a-Box (GraphDB) installations

Installations made with earlier versions of FLAIR-in-a-Box continue to work and are not affected. This document
applies to new installations.
