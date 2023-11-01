# CDE Templates for FLAIR-GG

## Location:

- filename:  location.csv
- yarrrml:  location_yarrrml.yaml

**bgvid**: string

**uniqid**: string (used to create context node)

**comment**: string

**collection_date**: ISO date

**collection_start**: ISO date

**collection_end**: ISO date

**country_code**: e.g. ES

**country_name**:  e.g. Spain

**latitude**:  float

**longitude**:  float

**soil_type**:  ontology term (unknown currently)

**soil_label**:  soil type (e.g. loam)



## Germplasm:

- filename:  germplasm.csv
- yarrrml:  germplasm.yaml

**bgvid**: string

**uniqid**: string (used to create context node)

**comment**: string


## Administrative:

- filename:  administrative.csv
- yarrrml:  administrative.yaml

**bgvid**: string

**uniqid**: string (used to create context node)

**org_name**: string

**org_id**:  web page or ROR entry.  MUST BE A UNIQUE URL!

**member_unique_id**:  any kind of unique identifier for that member.  Must be consistently used across all entries

**member_name**: Persons full name

**member_role**: SIO_000886 (author role); SIO_000885 (publisher role); SIO_000881 (investigational role)



