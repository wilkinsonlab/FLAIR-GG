require_relative "./SPO_pattern_class.rb"
require_relative "./Query_Matching_class.rb"

# ======================================================
#                 First section: Indexing              #
# ======================================================
engine = Engine.new

# Array of endpoints to be indexed
endpoints = ["https://rdf.metanetx.org/sparql", "http://fairdata.systems:7777/sparql", "http://fairdata.systems:7778/sparql", "https://bgv.cbgp.upm.es/repositories/germplasm", "https://bgv.cbgp.upm.es/repositories/location", "https://urjc.bgv.cbgp.upm.es/repositories/germplasm", "https://urjc.bgv.cbgp.upm.es/repositories/location", "https://jbo.bgv.cbgp.upm.es/repositories/germplasm", "https://jbo.bgv.cbgp.upm.es/repositories/location", "https://jbs.bgv.cbgp.upm.es/repositories/germplasm", "https://jbs.bgv.cbgp.upm.es/repositories/location", "https://bgusal.bgv.cbgp.upm.es/repositories/germplasm", "https://bgusal.bgv.cbgp.upm.es/repositories/location"]
# endpoints = ["https://urjc.bgv.cbgp.upm.es/repositories/germplasm", "https://urjc.bgv.cbgp.upm.es/repositories/location", "https://bgv.cbgp.upm.es/repositories/germplasm", "https://bgv.cbgp.upm.es/repositories/location"]

# The following lines perform the indexing and transformation to SHACL
rdf_index = engine.extract_patterns(endpoints)

puts rdf_index

shacl_index_gen = engine.shacl_generator(rdf_index, "shape_index", "create")
