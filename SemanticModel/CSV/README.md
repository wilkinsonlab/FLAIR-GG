# CDE Templates for FLAIR-GG

## Location:

- filename:  location.csv
- yarrrml:  location_yarrrml.pre-yaml

**bgvid**: String. 

**uniqid**: String (used to create context node)

**accession_number**: A unique identifier assigned to the germplasm accession by the managing organization. Integer

**national_catalogue_code**: A code representing the accession's registration or listing in a national germplasm or plant variety catalogue. Integer

**date_of_aquisition**: The date when the germplasm accession was acquired by the institution.  ISO 8601 (YYYY-MM-DD) formatted date.

**date_of_collection**: The date when the germplasm was collected from its source location.  ISO 8601 (YYYY-MM-DD) formatted date.

**collection_comment**: Notes or remarks about the circumstances of the germplasm collection.  String.

**location_comment**: Comments adding extra information or context about the location of the collection.  String.

**geographical_areas**: The geographic region or area where the germplasm was collected, from narrower to broader. E.g. Madrid, Comunidad de Madrid, España.  String

**country_name**: The name of the country where the germplasm was collected . String.  

**country_3letter_code**: The three-letter ISO code representing the country of collection.  String.

**country_2letter_code**: The two-letter ISO code for the country of collection.  String.

**soil_type**: The classification or description of the soil at the collection site.  One of the childs of envo:soil (check this website for all the options: https://ontobee.org/ontology/catalog/ENVO?iri=http://purl.obolibrary.org/obo/ENVO_00001998&max=100). IRI.

**longitude**: The longitudinal coordinate of the collection location.  Float

**latitude**: The latitudinal coordinate of the collection location.  Float

**coordinate_measurement_method**: The method used to determine the collection location's coordinates.  String

**coordinate_uncertanty_meters**: The uncertainty in meters associated with the recorded coordinates.  Float.

**location_minimum_elevation_meters**: The lowest elevation in meters at the collection site.  Float.

**location_maximum_elevation_meters**: The highest elevation in meters at the collection site.  Float.

**location_slope**: The degree of slope or incline at the collection location.  Float.

**geodetic_datum**: The geodetic reference system used for the recorded coordinates.  String.

**threat**: Information about potential threats to the germplasm or its habitat.  Choose from the following list: https://www.iucnredlist.org/resources/threat-classification-scheme  . String

**reaction_hcl**: Observations on the reaction of the soil to hydrochloric acid (indicating carbonate content).  Yes/No

**salty_types**: Description of salinity or salt types in the soil.  One of the following:

    - Undefined
    - Gypsum
    - Limestone
    - Marl
    - Saline efflorescences

**stonyness**: The extent or proportion of stones present in the soil.  One of the following:

    - Undefined
    - High
    - Medium
    - Low

**rockyness**: The presence or proportion of rocks at the collection site.  One of the following:

    - Undefined
    - High
    - Medium
    - Low

**texture**: The soil texture. One of the following:

    - Sand
    - Loam
    - Clay
    - Undefined


**leaf_litter**: The amount or type of leaf litter present on the soil surface. One of the following:

    - Undefined
    - High
    - Medium
    - Low

**plant_cover**: The percentage or type of plant cover at the collection site. One of the following:

    - Undefined
    - High
    - Medium
    - Low

**organic_matter**: The observed or measured organic matter content in the soil. String

**topography**: Description of the physical terrain at the collection site. String

**geology**: Information on the geological features or rock types in the area. String

**habitat**: Description of the natural environment or ecosystem of the collection site.  We recommend using one from FAO's multi-crop passport descriptors:

    10) Wild habitat
        11) Forest or woodland
        12) Shrubland
        13) Grassland
        14) Desert or tundra
        15) Aquatic habitat
    20) Farm or cultivated habitat
        21) Field
        22) Orchard
        23) Backyard, kitchen or home garden (urban, peri-urban or rural)
        24) Fallow land
        25) Pasture
        26) Farm store
        27) Threshing floor
        28) Park
    30) Market or shop
    40) Institute, Experimental station, Research organization, Genebank
    50) Seed company
    60) Weedy, disturbed or ruderal habitat
        61) Roadside
        62) Field margin

**associated_plant_species**: Other plant species found growing near or with the germplasm. String.

**land_use**: The type of land use or human activity at or near the collection location. String.


## Germplasm:

- filename:  germplasm.csv
- yarrrml:  germplasm.pre-yaml

**bgvid**: string

**uniqid**: string (used to create context node)

**org_name**: The name of the organization or institution responsible for managing, curating, or holding the germplasm accession. String

**collection_comment**: Comment about the collection process. String

**accession_number**: A unique identifier assigned to the germplasm accession by the managing organization. Integer

**national_catalogue_code**: A code representing the accession's registration or listing in a national germplasm or plant variety catalogue. Integer

**WFO_identifier**: taxon identifier in the World Flora Online taxonomy. String

**chosen_taxonomy_identifier**: taxon identifier in the preferred taxonomy for the germplasm resource (e.g.: lista patrón or World Checklist of Vascular Plants). String

**WFO_vernacular_name**: the common name of the germplasm species as recorded in World Flora Online. String

**WFO_scientific_name**: the botanical or scientific name of the germplasm accession as listed in World Flora Online. String

**WFO_scientific_name_authorship**: the author(s) who formally described the species, as recorded in World Flora Online. String.

**chosen_taxonomy_vernacular_name**: the common name of the germplasm accession based on the preferred taxonomy. String

**chosen_taxonomy_scientific_name**: the botanical or scientific name of the germplasm accession as listed in the preferred taxonomy. String

**chosen_taxonomy_scientific_name_authorship**: the author(s) who formally described the species, as recorded in the preferred taxonomy. String

**WFO_determination_status**: One of the following: String

    - Unverified ID (doubtful)
    - Provisional ID (some uncertainty)
    - Verified in field
    - Verified off field

**chosen_taxonomy_determination_status**: One of the following: String

    - Unverified ID (doubtful)
    - Provisional ID (some uncertainty)
    - Verified in field
    - Verified off field

**chosen_taxonomy_reference**: A citation or source for the preferred taxonomy. String.

**chosen_taxonomy_reference_url**: A web link to the chosen taxonomy reference or its online database entry. IRI

**lespre_endangerment_category**: Whether or not the species is recorded in LESPRE as endangered.

**iucn_endangerment_category**: One of the following: String

    - Data deficient
    - Least concern
    - Near threatened
    - Vulnerable
    - Endangered
    - Critically endangered
    - Extinct in the wild
    - Extinct



## Administrative:

- filename:  administrative.csv
- yarrrml:  administrative.pre-yaml

**bgvid**: string

**uniqid**: string (used to create context node)

**org_name**: string

**org_id**:  we recommend a ROR entry, or in case there isn't one, a web page .  MUST BE A UNIQUE URL!

**member_unique_id**:  any kind of unique identifier for that member.  Must be consistently used across all entries

**member_name**: Persons full name

**member_role**: SIO_000886 (author role); SIO_000885 (publisher role); SIO_000881 (investigational role)



