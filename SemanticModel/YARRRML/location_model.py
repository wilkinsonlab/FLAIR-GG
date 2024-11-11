from embuilder.builder import EMB
"""LOCATION MODEL"""

data = {
  "prefixes" : {
    "rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#" ,
    "rdfs" : "http://www.w3.org/2000/01/rdf-schema#" ,
    "sio" : "http://semanticscience.org/resource/" ,
    "geo" : "http://www.w3.org/2003/01/geo/wgs84_pos#" , 
    "efo" : "https://www.ebi.ac.uk/efo/" , 
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "fao": "https://w3id.org/fao-ipgr/multi-passport-descriptor.owl#",
    "edam" : "http://edamontology.org/",
    "bfo" : "http://purl.obolibrary.org/obo/BFO_",
    "dwc" : "http://rs.tdwg.org/dwc/terms/" ,
    "bco" : "http://purl.obolibrary.org/obo/BCO_",
    "envo" : " http://purl.obolibrary.org/obo/ENVO_",
    "this" : "http://my_example.com/"},
   

  "triplets" : [
    ["this:$(uniqid)#Collection","sio:SIO_000229","this:$(uniqid)#Germplasm","iri"], 
    ["this:$(uniqid)#GeoLocation","sio:SIO_000145","this:$(uniqid)#Collection","iri"],


    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#identifier", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#Accession_number", "iri"],
    ["this:$(uniqid)#Germplasm", "sio:SIO_000671", "this:$(uniqid)#National_catalogue_code", "iri"],

    ["this:$(uniqid)#identifier","sio:SIO_000300","$(bgvid)","xsd:string"],
    ["this:$(uniqid)#Accession_number","sio:SIO_000300","$(accession_number)","xsd:string"],
    ["this:$(uniqid)#National_catalogue_code","sio:SIO_000300","$(national_catalogue_code)","xsd:string"],

    ["this:$(uniqid)#identifier","rdf:type","SIO:000115","iri"],
    ["this:$(uniqid)#Accession_number","rdf:type","SIO:000115","iri"],
    ["this:$(uniqid)#National_catalogue_code","rdf:type","SIO:000115","iri"],

    ["this:$(uniqid)#Accession_number","rdf:type","fao:CO_020:0000089","iri"],
    ["this:$(uniqid)#National_catalogue_code","rdf:type","fao:national_catalogue_code","iri"],

    ["this:$(uniqid)#Collection","rdf:type","sio:SIO_001049","iri"], 
    ["this:$(uniqid)#Collection","rdfs:comment","$(collection_comment)","xsd:string"],
    ["this:$(uniqid)#Germplasm","rdf:type","efo:EFO_0007059","iri"],
    ["this:$(uniqid)#Germplasm", "rdf:type", "sio:SIO_000000", "iri"],
    ["this:$(uniqid)#Germplasm", "rdf:type", "prov:Entity", "iri"],

    ["this:$(uniqid)#Collection","fao:acquisition_time","this:$(uniqid)#Time_of_aquisition","iri"],
    ["this:$(uniqid)#Collection","fao:collecting_time","this:$(uniqid)#Time_of_collection","iri"],

    ["this:$(uniqid)#Time_of_aquisition","sio:SIO_000300","$(date_of_aquisition)","xsd:string"],
    ["this:$(uniqid)#Time_of_aquisition","rdf:type","sio:SIO_000391","iri"],
    ["this:$(uniqid)#Time_of_collection","sio:SIO_000300","$(date_of_collection)","xsd:string"],
    ["this:$(uniqid)#Time_of_collection","rdf:type","sio:SIO_000391","iri"],


    
    ["this:$(uniqid)#GeoLocation","rdf:type","geo:point","iri"],
    ["this:$(uniqid)#GeoLocation","rdfs:comment","$(location_comment)","iri"],
    ["this:$(uniqid)#GeoLocation","rdfs:comment","$(geographical_areas)","iri"],
    ["this:$(uniqid)#GeoLocation","bfo:located_in_at_all_times","this:$(uniqid)#Soil_type","iri"],
    ["this:$(uniqid)#GeoLocation","sio:SIO_000061","this:$(uniqid)#Country","iri"],
    ["this:$(uniqid)#Country","rdf:type","sio:SIO_000664","iri"],
    ["this:$(uniqid)#Country","rdf:label","$(country_name)", "xsd:string"],
    ["this:$(uniqid)#Country","rdf:label","$(country_3letter_code)", "xsd:string"],
    ["this:$(uniqid)#Country","rdf:label","$(country_2letter_code)", "xsd:string"],

    ["this:$(uniqid)#Soil_type","rdf:type","envo:soil","iri"],
    ["this:$(uniqid)#Soil_type","sio:SIO_000300","$(soil_type)","iri"],
    
    ["this:$(uniqid)#GeoLocation","geo:longitude","$(longitude)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","geo:latitude","$(latitude)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","bco:measurementMethod","$(coordinate_measurement_method)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","bco:coordinateUncertantyInMeters","$(coordinate_uncertanty_meters)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","bco:minimumElevationInMeters","$(location_minimum_elevation_meters)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","bco:maximumElevationInMeters","$(location_maximum_elevation_meters)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","sio:SIO_001184","$(location_slope)","xsd:float"],
    ["this:$(uniqid)#GeoLocation","dwc:geodeticDatum","$(geodetic_datum)","xsd:float"],

    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Threat","iri"],
    ["this:$(uniqid)#Threat", "SIO_000300", "$(threat)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Reaction_HCL","iri"],
    ["this:$(uniqid)#Reaction_HCL", "SIO_000300", "$(reaction_hcl)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Salty_types","iri"],
    ["this:$(uniqid)#Salty_types", "SIO_000300", "$(salty_types)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Stonyness","iri"],
    ["this:$(uniqid)#Stonyness", "SIO_000300", "$(stonyness)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Rockyness","iri"],
    ["this:$(uniqid)#Rockyness", "SIO_000300", "$(rockyness)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Texture","iri"],
    ["this:$(uniqid)#Texture", "SIO_000300", "$(texture)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Leaf_litter","iri"],
    ["this:$(uniqid)#Leaf_litter", "SIO_000300", "$(leaf_litter)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Plant_cover","iri"],
    ["this:$(uniqid)#Plant_cover", "SIO_000300", "$(plant_cover)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Organic_matter","iri"],
    ["this:$(uniqid)#Organic_matter", "SIO_000300", "$(organic_matter)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Topography","iri"],
    ["this:$(uniqid)#Topography", "SIO_000300", "$(topography)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Geology","iri"],
    ["this:$(uniqid)#Geology", "SIO_000300", "$(geology)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Habitat","iri"],
    ["this:$(uniqid)#Habitat", "SIO_000300", "$(habitat)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Associated_plant_species","iri"],
    ["this:$(uniqid)#Associated_plant_species", "SIO_000300", "$(associated_plant_species)", "xsd:string"],
    ["this:$(uniqid)#GeoLocation","SIO_000008","this:$(uniqid)#Land_use","iri"],
    ["this:$(uniqid)#Land_use", "SIO_000300", "$(land_use)", "xsd:string"],
    
  ],

  "config" : {
    "source_name" : "source_cde_test",
    "configuration" : "csv",    
    "csv_name" : "location.csv",
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