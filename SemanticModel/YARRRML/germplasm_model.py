from embuilder.builder import EMB
"""GERMPLASM MODEL"""

data = {
  "prefixes" : {
    "rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#" ,
    "rdfs" : "http://www.w3.org/2000/01/rdf-schema#" ,
    "sio" : "http://semanticscience.org/resource/" ,
    "efo" : "https://www.ebi.ac.uk/efo/" ,
    "dwc" : "http://rs.tdwg.org/dwc/terms/" ,
    "prov" :  "http://www.w3.org/ns/prov#" ,
    "edam" : "http://edamontology.org/",
    "fao": "https://w3id.org/fao-ipgr/multi-passport-descriptor.owl#",
    "xsd" : "http://www.w3.org/2001/XMLSchema#",
    "this" : "http://my_example.com/"},
   

  "triplets" : [
    ["this:$(bgvid)_$(uniqid)#Collection","sio:SIO_000229","this:$(uniqid)#Germplasm","iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasgeneratedby", "this:$(bgvid)_$(uniqid)#Collection", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#identifier", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#Accession_number", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#National_catalogue_code", "iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasUsedBy", "this:$(uniqid)#Plant_determination_process_WFO", "iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasUsedBy", "this:$(uniqid)#Plant_determination_process_chosen_taxonomy", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000231", "this:$(uniqid)#Plant_determination_process_WFO", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000231", "this:$(uniqid)#Plant_determination_process_chosen_taxonomy", "iri"],
    ["this:$(uniqid)#Plant_determination_process_WFO", "sio:SIO_000229", "this:$(uniqid)#Plant_identification_WFO", "iri"],
    ["this:$(uniqid)#Plant_determination_process_chosen_taxonomy", "sio:SIO_000229", "this:$(uniqid)#Plant_identification_chosen_taxonomy", "iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasUsedBy", "this:$(uniqid)#Endangerment_assesment_process_LESPRE", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000231", "this:$(uniqid)#Endangerment_assesment_process_IUCN", "iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasUsedBy", "this:$(uniqid)#Endangerment_assesment_process_LESPRE", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000231", "this:$(uniqid)#Endangerment_assesment_process_IUCN", "iri"],
    ["this:$(uniqid)#Endangerment_assesment_process", "sio:SIO_000229", "this:$(uniqid)#Endangerment_category_LESPRE", "iri"],
    ["this:$(uniqid)#Endangerment_assesment_process", "sio:SIO_000229", "this:$(uniqid)#Endangerment_category_IUCN", "iri"],
      

    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","prov:Activity","iri"],
    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","sio:SIO_1049","iri"],
    ["this:$(bgvid)_$(uniqid)#Collection","rdfs:comment","$(collection_comment)","xsd:string"],
    ["this:$(uniqid)#Germplasm", "rdf:type", "sio:SIO_000000", "iri"],
    ["this:$(uniqid)#Germplasm", "rdf:type", "efo:EFO_007059", "iri"],
    ["this:$(uniqid)#Germplasm", "rdf:type", "prov:Entity", "iri"],

    ["this:$(uniqid)#identifier","sio:SIO_000300","$(bgvid)","xsd:string"],
    ["this:$(uniqid)#Accession_number","sio:SIO_000300","$(accession_number)","xsd:string"],
    ["this:$(uniqid)#National_catalogue_code","sio:SIO_000300","$(national_catalogue_code)","xsd:string"],

    ["this:$(uniqid)#identifier","rdf:type","SIO:000115","iri"],
    ["this:$(uniqid)#Accession_number","rdf:type","SIO:000115","iri"],
    ["this:$(uniqid)#National_catalogue_code","rdf:type","SIO:000115","iri"],

    
    ["this:$(uniqid)#Accession_number","rdf:type","fao:CO_020:0000089","iri"],
    ["this:$(uniqid)#National_catalogue_code","rdf:type","fao:national_catalogue_code","iri"],

    ["this:$(uniqid)#Plant_determination_process_WFO", "rdf:type", "prov:activity", "iri"],
    ["this:$(uniqid)#Plant_determination_process_WFO", "rdf:type", "sio:SIO_000006", "iri"],
    ["this:$(uniqid)#Plant_determination_process_chosen_taxonomy", "rdf:type", "prov:activity", "iri"],
    ["this:$(uniqid)#Plant_determination_process_chosen_taxonomy", "rdf:type", "sio:SIO_000006", "iri"],

    ["this:$(uniqid)#Plant_identification_WFO", "dwc:vernacularName", "$(WFO_vernacular_name)", "iri"],
    ["this:$(uniqid)#Plant_identification_WFO", "rdf:type", "dwc:Taxon", "iri"],
    ["this:$(uniqid)#Plant_identification_WFO", "dwc:sientificName", "this:$(uniqid)#WFO_scientific_name", "iri"],
    ["this:$(uniqid)#Plant_identification_WFO", "dwc:sientificNameAuthorship", "$(WFO_scientific_name_authorship)", "iri"],

    ["this:$(uniqid)#WFO_scientific_name", "rdf:type", "dwc:scientificName", "iri"],
    ["this:$(uniqid)#WFO_scientific_name", "sio:SIO_000300", "$(WFO_scientific_name)", "xsd:string"],
    ["this:$(uniqid)#WFO_scientific_name", "dwc:nameAccordingTo", "WFO (2024): World Flora Online. Published on the Internet;http://www.worldfloraonline.org", "xsd:string"],
    ["this:$(uniqid)#WFO_scientific_name", "dwc:nameAccordingToID", "https://www.worldfloraonline.org/", "iri"],

    ["this:$(uniqid)#Plant_identification_chosen_taxonomy", "dwc:vernacularName", "$(chosen_taxonomy_vernacular_name)", "iri"],
    ["this:$(uniqid)#Plant_identification_chosen_taxonomy", "rdf:type", "dwc:Taxon", "iri"],
    ["this:$(uniqid)#Plant_identification_chosen_taxonomy", "dwc:sientificName", "this:$(uniqid)#Chosen_taxonomy_scientific_name", "iri"],

    ["this:$(uniqid)#Plant_identification_chosen_taxonomy", "dwc:sientificNameAuthorship", "$(chosen_taxonomy_scientific_name_authorship)", "iri"],

    ["this:$(uniqid)#Chosen_taxonomy_scientific_name", "rdf:type", "dwc:scientificName", "iri"],
    ["this:$(uniqid)#Chosen_taxonomy_scientific_name", "sio:SIO_000300", "$(chosen_taxonomy_scientific_name)", "xsd:string"],
    ["this:$(uniqid)#Chosen_taxonomy_scientific_name", "dwc:nameAccordingTo", "$(chosen_taxonomy_reference)", "xsd:string"],
    ["this:$(uniqid)#Chosen_taxonomy_scientific_name", "dwc:nameAccordingToID", "$(chosen_taxonomy_reference_url)", "iri"],

    ["this:$(uniqid)#Plant_identification_chosen_taxonomy", "sio:SIO_000671", "this:$(uniqid)#chosen_taxonomy_identifier", "iri"],
    ["this:$(uniqid)#Plant_identification_WFO", "sio:SIO_000671", "this:$(uniqid)#WFO_identifier", "iri"],

    ["this:$(uniqid)#chosen_taxonomy_identifier", "rdf:type", "sio:SIO_000115", "iri"],
    ["this:$(uniqid)#WFO_identifier", "rdf:type", "sio:SIO_000115", "iri"],
    ["this:$(uniqid)#chosen_taxonomy_identifier", "sio:SIO_000300", "$(chosen_taxonomy_identifier)", "xsd:string"],
    ["this:$(uniqid)#WFO_identifier", "sio:SIO_000300", "$(WFO_identifier)", "xsd:string"],

    ["this:$(uniqid)#Plant_identification_chosen_taxonomy", "sio:SIO_000008", "this:$(uniqid)#Determination_status_chosen_taxonomy", "iri"],
    ["this:$(uniqid)#Plant_identification_WFO", "sio:SIO_000008", "this:$(uniqid)#Determination_status_WFO", "iri"],

    ["this:$(uniqid)#Determination_status_chosen_taxonomy", "rdf:type", "fao:determination_status", "iri"],
    ["this:$(uniqid)#Determination_status_WFO", "rdf:type", "fao:determination_status", "iri"],
    ["this:$(uniqid)#Determination_status_chosen_taxonomy", "sio:SIO_000300", "$(chosen_taxonomy_determination_status)", "xsd:string"],
    ["this:$(uniqid)#Determination_status_WFO", "sio:SIO_000300", "$(WFO_determination_status)", "xsd:string"],

    ["this:$(uniqid)#Endangerment_assesment_process_LESPRE", "rdf:type", "sio:SIO_000006", "iri"],
    ["this:$(uniqid)#Endangerment_assesment_process_LESPRE", "rdf:type", "prov:activity", "iri"],
    ["this:$(uniqid)#Endangerment_assesment_process_IUCN", "rdf:type", "sio:SIO_000006", "iri"],
    ["this:$(uniqid)#Endangerment_assesment_process_IUCN", "rdf:type", "prov:activity", "iri"],
 
    ["this:$(uniqid)#Endangerment_category_LESPRE", "rdf:type", "fao:endangerment_category", "iri"],
    ["this:$(uniqid)#Endangerment_category_LESPRE", "sio:SIO_000300", "$(lespre_endangerment_category)", "iri"],
    ["this:$(uniqid)#Endangerment_category_IUCN", "rdf:type", "fao:endangerment_category", "iri"],
    ["this:$(uniqid)#Endangerment_category_IUCN", "sio:SIO_000300", "$(iucn_endangerment_category)", "iri"],






    ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "germplasm.csv",
    "basicURI" : "this"
    }
}

yarrrml = EMB(data["config"], data["prefixes"],data["triplets"])

#test_yarrrml = yarrrml.transform_ShEx()
#print(test_yarrrml)
test_yarrrml = yarrrml.transform_YARRRML()
print(test_yarrrml)
#test_obda = yarrrml.transform_OBDA()
#print(test_obda)
#test_sparql = yarrrml.transform_SPARQL()
#print(test_sparql)
