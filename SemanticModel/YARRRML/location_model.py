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
    ["this:$(uniqid)#Collection","sio:SIO_000229","this:$(uniqid)#Germplasm","iri"], 
    ["this:$(uniqid)#Collection","sio:SIO_000793","this:$(uniqid)#timeofobservation","iri"],
    ["this:$(uniqid)#Germplasm","sio:SIO_000671","this:$(uniqid)#identifier","iri"],
    ["this:$(uniqid)#timeofobservation","sio:SIO_000680","this:$(uniqid)#start","iri"],
    ["this:$(uniqid)#timeofobservation","sio:SIO_000681","this:$(uniqid)#end","iri"],
    ["this:$(uniqid)#GeoLocation","sio:SIO_000145","this:$(uniqid)#Collection","iri"],
    ["this:$(uniqid)#GeoLocation", "sio:SIO_000061", "$(country_name)", "iri"],
    ["this:$(uniqid)#GeoLocation","http://some.ontology.term/soiltype","this:$(uniqid)#soil_type","iri"],


    ["this:$(uniqid)#Collection","rdf:type","sio:SIO_001049","iri"], 
    ["this:$(uniqid)#Collection","rdfs:label","$(comment)","xsd:string"],
    ["this:$(uniqid)#Germplasm","rdf:type","efo:EFO_0007059","iri"],
    ["this:$(uniqid)#identifier","sio:SIO_000300","$(bgvid)","xsd:string"],
    ["this:$(uniqid)#timeofobservation","sio:SIO_000300","$(collection_date)","xsd:date"],
    ["this:$(uniqid)#timeofobservation","rdf:type","sio:SIO_000391","iri"], 
    ["this:$(uniqid)#timeofobservation","rdf:type","sio:SIO_000417","iri"],
    ["this:$(uniqid)#start","rdf:type","sio:SIO_000669","iri"],
    ["this:$(uniqid)#start","sio:SIO_000300","$(collection_start)","xsd:date"],
    ["this:$(uniqid)#end","sio:SIO_000300","$(collection_end)","xsd:date"], 
    ["this:$(uniqid)#end","rdf:type","sio:SIO_000670","iri"],  
    ["this:$(uniqid)#GeoLocation","rdf:type","$(latitude)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","rdf:type","$(longitude)","xsd:float"],
    ["this:$(uniqid)#soil_type","sio:SIO_000300","$(soil_label)","iri"],
    ["this:$(uniqid)#soil_type","rdf:type","$(soil_type)","iri"],
    ["$(country_name)", "rdf:type", "sio:SIO_000664", "iri"],
    ["$(country_name)", "rdfs:label", "$(country_name)","string"],
    ["$(country_name)", "rdfs:label", "$(country_code)","string"],
    
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