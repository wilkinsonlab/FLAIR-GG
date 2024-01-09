from embuilder.builder import EMB
"""LOCATION MODEL"""

data = {
  "prefixes" : {
    "rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#" ,
    "rdfs" : "http://www.w3.org/2000/01/rdf-schema#" ,
    "sio" : "http://semanticscience.org/resource/" ,
    "geo" : "http://www.w3.org/2003/01/geo/wgs84_pos#" , 
    "efo" : "https://www.ebi.ac.uk/efo/" , 
    "this" : "http://my_example.com/"},
   

  "triplets" : [
    ["this:$(uniqid)#Collection","sio:has-output","this:$(uniqid)#Germplasm","iri"], 
    ["this:$(uniqid)#Collection","sio:measured-at","this:$(uniqid)#Colecction_date","iri"],
    ["this:$(uniqid)#Collection_date","sio:SIO_000680","this:$(uniqid)#Collection_Start","iri"],
    ["this:$(uniqid)#Collection_date","sio:SIO_000681","this:$(uniqid)#Collection_End","iri"],
    ["this:$(uniqid)#Geolocation","sio:if-location-of","this:$(uniqid)#Collection","iri"],
    ["this:$(uniqid)#Geolocation", "sio:is-located-in", "https://en.wikipedia.org/wiki/ISO_3166-1:$(country_code)", "iri"]
    ["this:$(uniqid)#Geolocation"," ","this:$(uniqid)#Soil_type","iri"],


    ["this:$(uniqid)#Collection","rdf:type","sio:SIO_001049","iri"], 
    ["this:$(uniqid)#Collection","rdf:type","","iri"],


  

  ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "location.csv",
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