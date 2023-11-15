# Another thing I think will be useful is to find the URL patterns for each ?s and ?o
# (or at least, the most common ones... so maybe grab 10 examples of ?s and ?o and see
# what their URLs look like.  e.g.  http://purl.uniprot.org/P344556.)  The reason this may
# become useful is that EBI has agreed to resurrect a really useful service they used to have
# that finds synonyms for URLs. If we know the pattern, we might be able to do even more
# query expansion.
require "sparql/client"
require "digest"

# == SPO
#
# This class stores the Subject, Predicate and Object (SPO) of any RDF triple data.
#
# == Summary
# This class stores the components of triples.
#
class SPO
  # Get/Set the Subject of the triple.
  # @!attribute [rw]
  # @return [String] The Subject.
  attr_accessor :spo_subject

  # Get/Set the Predicate of the triple.
  # @!attribute [rw]
  # @return [String] The Predicate.
  attr_accessor :spo_predicate

  # Get/Set the Object of the triple.
  # @!attribute [rw]
  # @return [String] The Object.
  attr_accessor :spo_object

  # Creates a new instance of SPO pattern.
  #
  # @param spo_subject [String] the complete URI of the Subject of the SPO pattern.
  # @param spo_predicate [String] the complete URI of the Predicate of the SPO pattern.
  # @param spo_object [String] the complete URI of the Object of the SPO pattern.
  # @return [SPO] an instance of SPO.
  def initialize(spo_subject:, spo_predicate:, spo_object:)
    @spo_subject = spo_subject
    @spo_predicate = spo_predicate
    @spo_object = spo_object
  end
end

# == Engine
#
# This class handles all the endpoint indexing operations.
#
# == Summary
#
# Class that handles the indexing.
#
class Engine
  # Get/Set the hash of Subject-Predicate-Object (SPO) patterns.
  # @!attribute [rw]
  # @return [Hash] the patterns hash.
  attr_accessor :hashed_patterns

  # Get/Set the Array of SPO patterns.
  # @!attribute [rw]
  # @return [Array] the patterns array.
  attr_accessor :patterns

  # Creates a new instance of Engine.
  #
  # @param hashed_patterns [Hash] the hash of SPO patterns.
  # @param patterns [Array] the array of SPO patterns.
  # @return [Engine] an instance of Engine.
  def initialize
    @hashed_patterns = []
    @patterns = []
  end

  # Checks whether or not a triple has already been added to the SPO patterns hash.
  #
  # @param s [] the Subject of the triple.
  # @param p [] the Predicate of the triple.
  # @param o [] the Object of the triple.
  # @return [Boolean] True if the pattern already exists in the database and False if it does not.
  def in_database?(s, p, o)
    pattern_digest = Digest::SHA2.hexdigest s.to_s + p.to_s + o.to_s
    return true if hashed_patterns.include? pattern_digest

    hashed_patterns << pattern_digest
    false
  end

  # Adds the SPO pattern to the database as an instance of the SPO class.
  #
  # @type [String] the rdf:type of the Subject.
  # @param s [] the Subject of the triple.
  # @param p [] the Predicate of the triple.
  # @param o [] the Object of the triple.
  # @return [SPO] an instance of SPO.
  def add_triple_pattern(type, s, p, o)
    if @patterns.include? type
      @patterns[type] << SPO.new(
        spo_subject: s,
        spo_predicate: p,
        spo_object: o
      )
    else
      @patterns[type] = [SPO.new(
        spo_subject: s,
        spo_predicate: p,
        spo_object: o
      )]
    end
  end

  # Queries an endpoint to get information for its indexing.
  #
  # @param endpoint_URL [String] the URL of the SPARQL endpoint to be queried.
  # @param mode [String] There are three modes:
  #
  # * exploratory: queries the endpoint to get the rdf:types of all typed subjects inside of it.
  # * fixed_subject: given a subject type (rdf:type), queries the endpoint to get all the object types linked to it type and their corresponding predicates.
  # * fixed_object: given an object type, queries the endpoint to get all the subject types linked to it and their corresponding predicates.
  # @param type [String] The rdf:type of the subject or object for the fixed_subject and fixed_object modes.
  # @return [result] The result of the query.
  def query_endpoint(endpoint_url, mode = "exploratory", type = "")
    abort "must provide a type in any mode other than exploratory" if mode != "exploratory" && type.to_s.empty?
    sparql = SPARQL::Client.new(endpoint_url)
    case mode
    when  "exploratory"
      # This first query asks for the types of objects inside the triplestore
      query = <<~EXPLORE
        SELECT DISTINCT ?type
        WHERE {
            ?subject a ?type .
        }
      EXPLORE
      result = sparql.query(query)

    when "fixed_subject"
      query = <<~FIXEDSUB

        SELECT DISTINCT ?predicate ?object_type
        WHERE {
            ?subject a <#{type}>.
            ?subject ?predicate ?object .#{" "}
            OPTIONAL{?object a ?object_type}.
        } limit 10
      FIXEDSUB
      warn "query is:\n#{query}\n\n"
      result = sparql.query(query)

    when "fixed_object"
      query = <<~FIXEDOBJ

        SELECT DISTINCT ?predicate ?subject_type#{" "}
        WHERE {
            ?object a <#{type}>.
            ?subject ?predicate ?object .#{" "}
            OPTIONAL{?subject a ?subject_type}.
        } limit 10
      FIXEDOBJ
      warn "query is:\n#{query}\n\n"
      result = sparql.query(query)
    end
    result
  end

  # Uses the query_endpoint method to get all the SPO patterns present in an endpoint, creating an index.
  #
  # @param endpoint_URL [String] the URL of the SPARQL endpoint to be indexed.
  # @return [patterns] A hash containing all the SPO patterns as SPO instances.
  def extract_patterns(endpoint_urls:)
    endpoint_urls = [endpoint_urls] unless endpoint_urls.is_a? Array
    @endpoint_patterns = {}
    endpoint_urls.each do |endpoint_url|
      @patterns = {}
      types_array = []
      exploration_results = query_endpoint(endpoint_url, "exploratory")
      warn "#{exploration_results.length} types found"
      # The types are stored in an array so that they can be later explored individually in order
      exploration_results.each do |solution|
        next if solution[:type].to_s =~ /openlink/
        next if solution[:type].to_s =~ /w3\.org/

        # necessary because the ruby object wont be the same object, even if the content is the same
        next if types_array.include? solution[:type].to_s

        types_array << solution[:type].to_s
      end

      types_array.each do |type|
        # This query asks for the types of objects and the predicates that interact with each of the types
        fsubject_results = query_endpoint(endpoint_url, "fixed_subject", type)
        fsubject_results.each do |solution|
          next if solution[:object_type] =~ /rdf-schema/
          next if solution[:object_type] =~ /owl\#Ontology/

          # do a quick lookup to see if we already know this pattern
          # this will add it to teh database if it is not known
          next if in_database?(type, solution[:predicate], solution[:object_type])

          add_triple_pattern(type, type, solution[:predicate], solution[:object_type])
        end
        fobject_results = query_endpoint(endpoint_url, "fixed_object", type)
        fobject_results.each do |solution|
          # do a quick lookup to see if we already know this pattern
          # this will add it to teh database if it is not known
          next if in_database?(solution[:subject_type], solution[:predicate], type)

          add_triple_pattern(type, solution[:subject_type], solution[:predicate], type)
        end
      end
      @endpoint_patterns[endpoint_url] = @patterns
    end
    @endpoint_patterns
  end

  # Generates SHACL shapes corresponding to all the patterns from an endpoint and writes them to a file in turtle format.
  #
  # @param patterns_hash [Hash] The hash containing all the triple patterns from an endpoint as instances of SPO.
  # @param output_file [String] The name of the output file that will contain all the SHACL shapes. It is recommended to use .ttl as its extension.
  # @return [File] A file containing the SHACL shapes corresponding to all the SPO patterns given as input.
  def shacl_generator(patterns_hash:)
    patterns_hash.each do |_url, patterns|
      new_patterns_hash = {}
      @shacl = []
      header = <<~HEADER
        @prefix dash: <http://datashapes.org/dash#> .
        @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix schema: <http://schema.org/> .
        @prefix sh: <http://www.w3.org/ns/shacl#> .
        @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

      HEADER
      @shacl << header
      patterns.each do |_key, value|
        value.each do |pattern|
          if new_patterns_hash.include? pattern.spo_subject.to_s
            new_patterns_hash[pattern.spo_subject.to_s] << pattern
          else
            new_patterns_hash[pattern.spo_subject.to_s] = [pattern]
          end
        end
      end
      new_patterns_hash.each do |key, value|
        process_shape(key: key, value: value) # updates @shacl
      end
    end
    @shacl.join.to_s
  end

  def process_shape(key:, value:)
    warn "Processing #{key}'s shape"
    shape_intro = "<#{key}Shape>\n\ta sh:NodeShape ;\n\tsh:targetClass <#{key}> ;\n"
    @shacl << shape_intro
    @counter = 0
    value.each do |pattern|
      next unless key == pattern.spo_subject

      process_pattern(value: value, pattern: pattern)  # updates @shacl
    end
  end

  def process_pattern(value:, pattern:)
    @counter += 1
    property_text = ""
    if @counter == value.select { |a| a.spo_subject == pattern.spo_subject }.length
      if pattern.spo_object.nil?
        property_text = "\tsh:property [\n\t\tsh:path <#{pattern.spo_predicate}> ;\n\t] .\n\n"
      else
        property_text = "\tsh:property [\n\t\tsh:path <#{pattern.spo_predicate}> ;\n\t\tsh:class <#{pattern.spo_object}> ;\n\t] .\n\n"
      end
    elsif pattern.spo_object.nil?
      property_text = "\tsh:property [\n\t\tsh:path <#{pattern.spo_predicate}> ;\n\t] ;\n"
    else
      property_text = "\tsh:property [\n\t\tsh:path <#{pattern.spo_predicate}> ;\n\t\tsh:class <#{pattern.spo_object}> ;\n\t] ;\n"
    end
    @shacl << property_text
  end
end
