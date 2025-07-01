from embuilder.builder import EMB
"""LOCATION MODEL"""

data = {
  "prefixes" : {
    "bfo": "http://purl.obolibrary.org/obo/BFO_",
    "dwc": "http://rs.tdwg.org/dwc/terms/",
    "efo": "http://www.ebi.ac.uk/efo/",
    "envo": "http://purl.obolibrary.org/obo/ENVO_",
    "fao": "https://w3id.org/fao-ipgr/multi-passport-descriptor.owl#CO_020:",
    "obi": "http://purl.obolibrary.org/obo/OBI_",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "sio": "http://semanticscience.org/resource/SIO_",
    "this" : "http://my_example.com/"},
   

  "triplets" : [
    ["this:$(uniqid)#Accession_number", "rdf:type", "fao:0000089", "iri"], #accession number
    ["this:$(uniqid)#Accession_number", "rdf:type", "sio:000115", "iri"], #identifier
    ["this:$(uniqid)#Accession_number","sio:000300","$(accession_number)","xsd:string"], #has value

    ["this:$(uniqid)#Germplasm", "sio:000671", "this:$(uniqid)#Accession_number", "iri"], #has identifier
    ["this:$(uniqid)#Germplasm", "rdf:type", "sio:000000", "iri"], #entity
    ["this:$(uniqid)#Germplasm", "rdf:type", "efo:007059", "iri"], #germplasm
    ["this:$(uniqid)#Germplasm", "sio:000671", "this:$(uniqid)#National_catalogue_code", "iri"], #has identifier

    ["this:$(uniqid)#National_catalogue_code","sio:000300","$(national_catalogue_code)","xsd:string"], #has value
    ["this:$(uniqid)#National_catalogue_code","rdf:type","sio:000115","iri"], #identifier
    ["this:$(uniqid)#National_catalogue_code","rdf:type","fao:0000129","iri"],#national catalogue code

    ["this:$(uniqid)#Collection_process","sio:000229","this:$(uniqid)#Germplasm","iri"],#has output
    ["this:$(uniqid)#Collection_process","rdf:type","sio:000006","iri"],#process
    ["this:$(uniqid)#Collection_process","rdf:type","obi:0000744","iri"], #material sampling process
    ["this:$(uniqid)#Collection_process","fao:0000131","$(acquisition_time)","xsd:date"], #acquisition time
    ["this:$(uniqid)#Collection_process","fao:0000132","$(collecting_time)","xsd:date"], #collecting date of sample

    ["this:$(uniqid)#Geolocation","sio:000145","this:$(uniqid)#Collection_process",""], #is location of
    ["this:$(uniqid)#Geolocation","rdf:type","sio:000000","iri"], #entity
    ["this:$(uniqid)#Geolocation","rdf:type","dwc:Location","iri"],

    ["this:$(uniqid)#Geolocation","bfo:0000082","this:$(uniqid)#Soil_type","iri"], #located in at all times
    ["this:$(uniqid)#Soil_type","rdf:type","sio:000000","iri"],
    ["this:$(uniqid)#Soil_type","rdf:type","envo:soil","iri"],
    ["this:$(uniqid)#Soil_type","sio:000300","$(soil_type)","xsd:string"],

    ["this:$(uniqid)#Geolocation","dwc:decimalLatitude","$(latitude)","xsd:string"],
    ["this:$(uniqid)#Geolocation","dwc:decimalLongitude","$(longitude)","xsd:string"],
    ["this:$(uniqid)#Geolocation","dwc:coordinateUncertaintyInMeters","$(coordinate_uncertainty)","xsd:float"],
    ["this:$(uniqid)#Geolocation","dwc:geodeticDatum","$(geodetic_datum)","xsd:string"],
    ["this:$(uniqid)#Geolocation","dwc:maximumElevationInMeters","$(maximum_elevation)","xsd:float"],
    ["this:$(uniqid)#Geolocation","dwc:minimumElevationInMeters","$(minimum_elevation)","xsd:float"],
    ["this:$(uniqid)#Geolocation","fao:0000133","$(terrain_inclination)","xsd:string"], #terrain inclination
    ["this:$(uniqid)#Geolocation","dwc:country","$(country_name)","xsd:string"],
    ["this:$(uniqid)#Geolocation","dwc:countryCode","$(country_2letter_code)","xsd:string"],
    ["this:$(uniqid)#Geolocation","dwc:stateProvince","$(first_admin_subdivision)","xsd:string"], #first order administrative region
    ["this:$(uniqid)#Geolocation","dwc:county","$(second_admin_subdivision)","xsd:string"],# second order administrative region
    ["this:$(uniqid)#Geolocation","dwc:municipality","$(third_admin_subdivision)","xsd:string"],# third order administrative region
    ["this:$(uniqid)#Geolocation","dwc:locality","$(fourth_admin_subdivision)","xsd:string"], #fourth order administrative region
    ["this:$(uniqid)#Geolocation","dwc:verbatimLocality","$(locality_description)","xsd:string"],  
  ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "default",    
    "csv_name" : "location",
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