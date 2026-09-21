
  

# CSV Templates for FLAIR-GG

There are three CSV files, and **their filenames are fixed**: `admin.csv`, `germplasm.csv` and `location.csv`.
Each is optional - if you do not provide a file, that type of data is simply not published (for example, leave
out `location.csv` if your collection locations are sensitive). Put the files in the `data` folder of your
Sextans Fix installation (see the [FLAIR-in-a-Box instructions](../../FLAIR-in-a-box/)).

Dates must be ISO 8601 (`YYYY-MM-DD`, e.g. `2025-01-01`, **not** `2025/01/01`); a file with invalid values
is rejected and nothing is loaded.


  

  

## Location model:

  

  

- filename: location.csv

  

- yarrrml: location_yarrrml.pre-yaml

  


**uniqid**: Unique ID for the accession. Can be created by transforming the timestamp at the time of creation of the accession entry into a number.

- Example: 20250224120108014344

  

**accession_number**: A unique identifier assigned to the germplasm accession by the managing organization.

- Data type: Integer (numeric value without a fractional component).

- Example: 483

  

  

**national_catalogue_code**: A code representing the accession's registration or listing in a national germplasm or plant variety catalogue.

- Data type: Integer (numeric value without a fractional component).

- Example: NC059118
  

  

**acquisition_time**: The date when the germplasm accession was acquired by the institution. ISO 8601 (YYYY-MM-DD) formatted date.
-Data type: Date (ISO 8601 (YYYY-MM-DD) formatted)
-Example: 2025-01-01

**collecting_time**: The date when the germplasm was collected from its source location. ISO 8601 (YYYY-MM-DD) formatted date.
-Data type: Date (ISO 8601 (YYYY-MM-DD) formatted)
-Example: 2025-01-01
  

  

**soil_type**: The classification or description of the soil at the collection site. One of the subcategories of envo:soil (check this website for all the options: https://ontobee.org/ontology/catalog/ENVO?iri=http://purl.obolibrary.org/obo/ENVO_00001998&max=100). 
-Data type: URI (URL)

  

**latitude**: The latitudinal coordinate of the collection location.
-Data type: Float (numeric value with a fractional component).
-Example: -121.17
  

**longitude**: The longitudinal coordinate of the collection location. 
-Data type: Float (numeric value with a fractional component).
-Example: -41.098
  

**coordinate_uncertanty**: The uncertainty in meters associated with the recorded coordinates.
-Data type: Float (numeric value with a fractional component).
-Example: 30
  

**geodetic_datum**: The geodetic reference system used for the recorded coordinates.
-Data type: String (contains characters, including alphanumerical values)
-Example: WGS84
  

**maximum_elevation**: The highest elevation in meters at the collection site.
-Data type: Float (numeric value with a fractional component).
-Example: 20
  

**minimum_elevation**: The lowest elevation in meters at the collection site. 
-Data type: Float (numeric value with a fractional component).
-Example: 12
  

**terrain_inclination**: The degree of slope or incline at the collection location.
-Data type: Float (numeric value with a fractional component).
-Example: 12
  

**country_name**: Name of the country where the accession was collected from. 
-Data type: String (contains characters, including alphanumerical values)
-Example: Spain
  

**country_2letter_code**: ISO 3166-2 Alpha 2 code that corresponds to the country where the accession was collected from. 
-Data type: String (contains characters, including alphanumerical values)
-Example: ES
  

**first_admin_subdivision**: First administrative subdivision of the location where the accession was collected from. In the case of Spain, this represents the Comunidades/Comunidades autónomas. 
-Data type: String (contains characters, including alphanumerical values)
-Example: Comunidad de Madrid.
  

**second_admin_subdivision**: Second administrative subdivision of the location where the accession was collected from. In the case of Spain, this represents Provinces. 
-Data type: String (contains characters, including alphanumerical values)
-Example: Madrid
  

**third_admin_subdivision**: Third administrative subdivision of the location where the accession was collected from. In the case of Spain, this represents the municipalities. 
-Data type: String (contains characters, including alphanumerical values)
-Example: Madrid
  

**fourth_admin_subdivision**: Fourth administrative subdivision of the location where the accession was collected from. In the case of Spain, this represents the neighborhoods. 
-Data type: String (contains characters, including alphanumerical values)
-Example: Ciudad Universitaria.
  

**locality_description**: Textual description of the location where the accession was collected from, as it originally appeared in the database.
-Data type: String (contains characters, including alphanumerical values)
-Example: 25km from Ciudad Universitaria.
  

## Germplasm model:

  

We require the use of [World Flora Online](https://www.worldfloraonline.org) as the common taxonomy, allowing us to harmonize taxon information. If you also want to include information about an accession using other taxonomies (like Lista Patrón for example), you should create a new row in the CSV, with a different uniqid.

  

- filename: germplasm.csv

  

- yarrrml: germplasm_yarrrml.pre-yaml

  
  

**uniqid**: Unique ID for the accession. Can be created by transforming the timestamp at the time of creation of the accession entry into a number.

- Example: 20250224120108014344

  

**accession_number**: A unique identifier assigned to the germplasm accession by the managing organization.

- Data type: Integer (numeric value without a fractional component).

- Example: 483

  

  

**national_catalogue_code**: A code representing the accession's registration or listing in a national germplasm or plant variety catalogue.

- Data type: Integer (numeric value without a fractional component).

- Example: NC059118

  

**taxon_identifier**: The identifier for the taxon, as provided by the taxonomy. We require the use of [World Flora Online](https://www.worldfloraonline.org) as the common taxonomy, as a way to harmonize taxon identifiers, but you can also create an additional entry using the original taxonomy.

- Data type: String (contains characters, including alphanumerical values)

- Example: https://www.worldfloraonline.org/taxon/wfo-0000380363

  

**scientific_name**: the botanical or scientific name of the germplasm accession as listed in the selected ontology.

-Data type: String (contains characters, including alphanumerical values)

-Example: Noccaea montana (L.) F.K.Mey.

  

**scientific_name_authorship**: the author(s) who formally described the species, as recorded in the selected ontology.
-Data type: String (contains characters, including alphanumerical values)
-Example: (L.) F.K.Mey.

  

**vernacular_name**: the common name of the germplasm species.
-Data type: String (contains characters, including alphanumerical values)
-Example: Repollo

**taxonomy_reference**: bibliographic citation of the selected taxonomy. 
-Data type: String
-Example: WFO (2025): World Flora Online. Published on the Internet;  [http://www.worldfloraonline.org](http:// www.worldfloraonline.org/). Accessed on: 29 May 2025'

**determination_status**: Indicator of the level of confidence and verification associated with the identification of an accession.
- Unverified ID (doubtful)
- Provisional ID (some uncertainty)
- Verified in field
- Verified off field

**iucn_endangerment_category**: National IUCN threat status assessment. Choose one of the terms in this link: https://rs.gbif.org/vocabulary/iucn/threat_status.xml
-Data type: URI (A URL)
-Example: http://rs.gbif.org/vocabulary/iucn/threat_status/CR


## Administrative model:

- filename: admin.csv

- yarrrml: admin_yarrrml.pre-yaml

An example file is provided: [admin.csv](./admin.csv).

**bgvid**: Short identifier for your collection/bank. Combined with `uniqid` to name the collection record.
- Data type: String
- Example: bgv123

**uniqid**: Unique ID for the accession; use the same value as in the corresponding rows of `location.csv` and `germplasm.csv`.
- Example: 1234567

**org_name**: Name of the organization that holds the collection.
- Data type: String
- Example: UPM BGV

**org_id**: A persistent URI identifying the organization (for example its home page).
- Data type: URI (A URL)
- Example: http://www.bancodegermoplasma.upm.es/

**member_unique_id**: Identifier of the person who is responsible for the accession within the organization.
- Example: 163483

**member_name**: Name of that person.
- Data type: String
- Example: Santiago Moreno

**member_role**: URI of the role that person plays.
- Data type: URI (A URL)
- Example: http://semanticscience.org/resource/SIO_000886

**collection_comment**: Free-text comment about the collection.
- Data type: String
- Example: interesting collection

**collecting_institute_code**: Code of the institute that collected the accession.
- Data type: String
- Example: 1234

**holder_institute_code**: Code of the institute that currently holds the accession.
- Data type: String
- Example: 1234
