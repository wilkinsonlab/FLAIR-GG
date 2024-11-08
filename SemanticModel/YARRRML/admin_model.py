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
    "fao" : "https://w3id.org/fao-ipgr/multi-passport-descriptor.owl#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",  
    "this" : "http://my_example.com/"},
    

  "triplets" : [
    ["this:$(bgvid)_$(uniqid)#Collection","prov:wasAssociatedWith","$(org_id)","iri"], 
    ["$(org_id)","sio:SIO_000671","this:$(uniqid)#identifier","iri"],
    ["$(org_id)","sio:SIO_000059","this:$(uniqid)#individual","iri"],
    ["this:$(uniqid)#individual","sio:SIO_000228","this:$(uniqid)#Role","iri"],
    ["this:$(uniqid)#individual", "org:role", "this:$(uniqid)#Role","iri"],
    
    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","sio:SIO_001049","iri"], 
    ["this:$(bgvid)_$(uniqid)#Collection","rdf:type","prov:activity","iri"],
    ["this:$(bgvid)_$(uniqid)#Collection", "rdfs:comment", "$(collection_comment)", "xsd:string"],
    ["this:$(bgvid)_$(uniqid)#Collection","fao:CO_020:0000004", "$(collecting_institute_code)", "xsd:string"],
    ["this:$(bgvid)_$(uniqid)#Collection","fao:CO_020:0000088", "$(holder_institute_code)", "xsd:string"],
    ["$(org_id)","rdf:type","prov:Agent","iri"],
    ["$(org_id)","rdfs:label","$(org_name)","xsd:string"], 
    ["$(org_id)","rdf:type","org:Organization","iri"],
    ["$(org_id)","rdf:type","sio:SIO_000012","iri"],
    ["this:$(uniqid)#identifier","sio:SIO_000300","$(org_id)","xsd:string"], 
    ["this:$(uniqid)#individual","foaf:name","$(member_name)","xsd:string"], 
    ["this:$(uniqid)#individual","rdf:type","prov:Agent","iri"],
    ["this:$(uniqid)#individual","rdf:type","org:Membership","iri"],
    ["this:$(uniqid)#individual","rdf:type","sio:SIO_000498","iri"],
    ["this:$(uniqid)#Role","rdf:type","org:role","iri"],
    ["this:$(uniqid)#Role","rdf:type","$(member_role)","iri"], 
  ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "administrative.csv",
    "basicURI" : "this"
    }
}

yarrrml = EMB(data["config"], data["prefixes"],data["triplets"])

# test_yarrrml = yarrrml.transform_ShEx()
# print(test_yarrrml)
# test_shex = yarrrml.transform_YARRRML()
# print(test_shex)
# test_obda = yarrrml.transform_OBDA()
# print(test_obda)
# test_sparql = yarrrml.transform_SPARQL()
# print(test_sparql)

test_yarrrml = yarrrml.transform_YARRRML()
print(test_yarrrml)

