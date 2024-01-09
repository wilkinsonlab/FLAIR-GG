from embuilder.builder import EMB
"""ADMINISTRATIVE MODEL"""

data = {
  "prefixes" : {
    "rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#" ,
    "rdfs" : "http://www.w3.org/2000/01/rdf-schema#" ,
    "sio" : "http://semanticscience.org/resource/" ,
    "foaf" : "http://xmlns.com/foaf/0.1/" , 
    "prov" : "https://www.w3.org/ns/prov#" , 
    "org" : "https://www.w3.org/ns/org#", 
    "this" : "http://my_example.com/"},
    

  "triplets" : [
    ["this:$(bgvid)_$(uniqid)#Collection","prov:wasAssociatedWith","$(org_id)","iri"], #Organization?
    ["$(org_id)","sio:000671","this:$(uniqid)#Identifier","iri"],
    ["$(org_id)","sio:000059","this:$(uniqid)#Individual","iri"],
    ["this:$(uniqid)#Individual","sio:000228","this:$(uniqid)#Role","iri"],
    
    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","sio:001049","iri"], 
    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","prov:activity","iri"],
    ["$(org_id)","rdf:type","prov:Agent","iri"],
    ["$(org_id)","rdfs:label","$(org_name)","string"], #Value
    ["$(org_id)","rdf:type","org:Organization","iri"],
    ["$(org_id)","rdf:type","sio:000012","iri"],
    ["this:$(uniqid)#Identifier","sio:000300","$(org_id)","xsd:string"], #url?
    ["this:$(uniqid)#Individual","foaf:name","$(member_name)","xsd:string"], #value
    ["this:$(uniqid)#Individual","rdf:type","prov:Agent","iri"],
    ["this:$(uniqid)#Individual","rdf:type","org:Membership","iri"],
    ["this:$(uniqid)#Individual","rdf:type","sio:SIO_000498","iri"],
    ["this:$(uniqid)#Role","rdf:type","org:role","iri"],
    ["this:$(uniqid)#Role","rdf:type","$(member_role)","iri"], 
  ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "atributos BANSEM_c_etl_smv_6",
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