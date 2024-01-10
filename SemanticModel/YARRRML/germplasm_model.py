from embuilder.builder import EMB
"""GERMPLASM MODEL"""

data = {
  "prefixes" : {
    "rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#" ,
    "rdfs" : "http://www.w3.org/2000/01/rdf-schema#" ,
    "sio" : "http://semanticscience.org/resource/" ,
    "geo" : "http://www.w3.org/2003/01/geo/wgs84_pos#" , 
    "efo" : "https://www.ebi.ac.uk/efo/" ,
    "dwc" : "http://rs.tdwg.org/dwc/terms" ,
    "prov" :  "http://www.w3.org/ns/prov#" ,
    "this" : "http://my_example.com/"},
   

  "triplets" : [
    ["this:$(bgvid)_$(uniqid)#Collection","sio:SIO_000229","this:$(uniqid)#Germplasm","iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasgeneratedby", "this:$(bgvid)_$(uniqid)#Collection", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#identifier", "iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasUsedBy", "this:$(uniqid)#Plant_identification_process", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000231", "this:$(uniqid)#Plant_identification_process", "iri"],
    ["this:$(uniqid)#Plant_identification_process", "sio:SIO_000229", "this:$(uniqid)#Plant_identification", "iri"],
    ["this:$(uniqid)#Germplasm", "prov:wasUsedBy", "this:$(uniqid)#Endangerment_assesment_process", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000231", "this:$(uniqid)#Endangerment_assesment_process", "iri"],
    ["this:$(uniqid)#Endangerment_assesment_process", "sio:SIO_000229", "this:$(uniqid)#Endangerment_category", "iri"],
      

    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","prov:Activity","iri"],
    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","sio:SIO_1049","iri"],
    ["this:$(bgvid)_$(uniqid)#Collection","rdfs:label","$(comment)","xsd:string"],








    ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "germplasm.csv",
    "basicURI" : "this"
    }
}

yarrrml = EMB(data["config"], data["prefixes"],data["triplets"])

test_yarrrml = yarrrml.transform_ShEx()
print(test_yarrrml)
test_shex = yarrrml.transform_YARRRML()
print(test_shex)
test_obda = yarrrml.transform_OBDA()
print(test_obda)
test_sparql = yarrrml.transform_SPARQL()
print(test_sparql)