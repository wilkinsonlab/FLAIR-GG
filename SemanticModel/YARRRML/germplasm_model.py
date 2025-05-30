from embuilder.builder import EMB
"""GERMPLASM MODEL"""

data = {
  "prefixes" : {
    "bco": "http://purl.obolibrary.org/obo/BCO_",
    "dwc": "http://purl.org/dc/terms/",
    "efo": "https://www.ebi.ac.uk/efo/",
    "fao": "https://w3id.org/fao-ipgr/multi-passport-descriptor.owl#",
    "iucn": "http://iucn.org/terms/",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "sio": "http://semanticscience.org/resource/SIO_",
    "this" : "http://my_example.com/"},

  "triplets" : [
    ["this:$(uniqid)#Accession_number", "rdf:type", "fao:accession_number", "iri"],
    ["this:$(uniqid)#Accession_number", "rdf:type", "sio:000115", "iri"], #identifier
    ["this:$(uniqid)#Accession_number","sio:000300","$(accession_number)","xsd:string"], #has value
    ["this:$(uniqid)#Germplasm", "sio:000671", "this:$(uniqid)#Accession_number", "iri"], #has identifier
    ["this:$(uniqid)#Germplasm", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#Germplasm", "rdf:type", "efo:007059", "iri"], #germplasm
    ["this:$(uniqid)#Germplasm", "sio:000671", "this:$(uniqid)#National_catalogue_code", "iri"], #has identifier

    ["this:$(uniqid)#National_catalogue_code","sio:000300","$(national_catalogue_code)","xsd:string"], #has value
    ["this:$(uniqid)#National_catalogue_code","rdf:type","sio:000115","iri"], #identifier
    ["this:$(uniqid)#National_catalogue_code","rdf:type","fao:national_catalogue_code","iri"],

    ["this:$(uniqid)#Germplasm", "bco:0000087", "this:$(uniqid)#Taxon", "iri"],  #member of taxon
    ["this:$(uniqid)#Taxon", "rdf:type", "dwc:Taxon", "iri"],
    ["this:$(uniqid)#Taxon", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#Taxon", "dwc:taxonID", "$(taxon_identifier)", "xsd:string"],
    ["this:$(uniqid)#Taxon", "iucn:threatStatus", "$(iucn_threat_category)", "xsd:string"],
    ["this:$(uniqid)#Taxon", "dwc:scientificName", "$(scientific_name)", "xsd:string"],
    ["this:$(uniqid)#Taxon", "dwc:scientificNameAuthorship", "$(scientific_name_authorship)", "xsd:string"], 
    ["this:$(uniqid)#Taxon", "dwc:vernacularName", "$(vernacular_name)", "xsd:string"], 
    ["this:$(uniqid)#Taxon", "dwc:nameAccordingTo", "$(taxonomy_reference)", "xsd:string"],

    ["this:$(uniqid)#Taxon", "sio:000008", "this:$(uniqid)#Determination_status", "iri"], #has attribute    
    ["this:$(uniqid)#Determination_status", "sio:000300", "$(determination_status)", "xsd:string"], #has value
    ["this:$(uniqid)#Determination_status", "rdf:type", "fao:determination_status", "iri"], 
    ["this:$(uniqid)#Determination_status", "rdf:type", "sio:000000", "iri"], #entity

  ],
  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "germplasm.csv",
    "basicURI" : "this"
    }
  }    

yarrrml = EMB(data["config"], data["prefixes"],data["triplets"])

test_yarrrml = yarrrml.transform_YARRRML()
print(test_yarrrml)
