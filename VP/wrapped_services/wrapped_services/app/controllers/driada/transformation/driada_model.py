from embuilder.builder import EMB
"""DRIADA MODEL"""

data = {
  "prefixes" : {
    "bibo" : "http://purl.org/ontology/bibo/",
    "dct" : "http://purl.org/dc/terms/",
    "dwc": "http://purl.org/dc/terms/",
    "gsso" : "http://purl.obolibrary.org/obo/GSSO_",
    "ncit" : "http://purl.obolibrary.org/obo/NCIT_",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "sio": "http://semanticscience.org/resource/SIO_",
    "this" : "http://my_example.com/"},

  "triplets" : [
    ["this:$(uniqid)#Taxon", "rdf:type", "dwc:Taxon", "iri"],
    ["this:$(uniqid)#Taxon", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#Taxon", "dwc:taxonID", "$(taxonID)", "xsd:string"],
    ["this:$(uniqid)#Taxon", "dwc:scientificName", "$(scientific_name)", "xsd:string"],
    ["this:$(uniqid)#Taxon", "dwc:nameAccordingTo", "$(taxonomy_reference)", "xsd:string"],

    ["this:$(uniqid)#Taxon", "sio:000008", "this:$(uniqid)#Protection_category", "iri"], #has attribute
    ["this:$(uniqid)#Protection_category", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#Protection_category", "rdf:type", "gsso:003562", "iri"],#legal status
    ["this:$(uniqid)#Protection_category", "sio:000300", "$(protection_category)", "iri"], #has value
    ["this:$(uniqid)#Protection_category", "dct:source", "this:$(uniqid)#BOE", "iri"],

    ["this:$(uniqid)#BOE", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#BOE", "rdf:type", "bibo:LegalDocument", "iri"],
    ["this:$(uniqid)#BOE", "dct:title", "$(BOE_name)", "xsd:string"],
    ["this:$(uniqid)#BOE", "sio:000628", "$(referred_population)", ""], #refers to
    ["this:$(uniqid)#BOE", "bibo:volume", "$(BOE_volume)", "xsd:integer"],
    ["this:$(uniqid)#BOE", "dct:issued", "$(BOE_publication_date)", "xsd:string"],
    ["this:$(uniqid)#BOE", "bibo:pages", "$(BOE_pages)", "xsd:string"],
    ["this:$(uniqid)#BOE", "dct:publisher", "this:$(uniqid)#BOE_creator", "iri"],
    ["this:$(uniqid)#BOE_creator", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#BOE_creator", "rdf:type", "ncit:authority", "iri"],
    ["this:$(uniqid)#BOE_creator", "sio:000300", "$(BOE_creator)", ""], #has value

  ],
  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "driada.csv",
    "basicURI" : "this"
    }
  }    

yarrrml = EMB(data["config"], data["prefixes"],data["triplets"])

test_yarrrml = yarrrml.transform_YARRRML()
print(test_yarrrml)
