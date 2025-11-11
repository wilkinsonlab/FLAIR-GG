require "sparql/client"
require "digest"
require "set"  # added for hashed_patterns

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
  attr_accessor :SPO_Subject

  # Get/Set the Predicate of the triple.
  # @!attribute [rw]
  # @return [String] The Predicate.
  attr_accessor :SPO_Predicate

  # Get/Set the Object of the triple.
  # @!attribute [rw]
  # @return [String] The Object.
  attr_accessor :SPO_Object

  # Creates a new instance of SPO pattern.
  #
  # @param SPO_Subject [String] the complete URI of the Subject of the SPO pattern.
  # @param SPO_Predicate [String] the complete URI of the Predicate of the SPO pattern.
  # @param SPO_Object [String] the complete URI of the Object of the SPO pattern.
  # @return [SPO] an instance of SPO.
  def initialize(params = {})
    @SPO_Subject   = params.fetch(:SPO_Subject, "")
    @SPO_Predicate = params.fetch(:SPO_Predicate, "")
    @SPO_Object    = params.fetch(:SPO_Object, "")
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
  def initialize(params = {})
    @hashed_patterns = Set.new  # now a Set for unique digests
    @patterns        = {}       # now a Hash for keyed access
  end

  # Checks whether or not a triple has already been added to the SPO patterns hash. 
  #
  # @param s [] the Subject of the triple.
  # @param p [] the Predicate of the triple.
  # @param o [] the Object of the triple.
  # @return [Boolean] True if the pattern already exists in the database and False if it does not.
  def in_database?(s, p, o)
    pattern_digest = Digest::SHA2.hexdigest s.to_s + p.to_s + o.to_s
    return true if @hashed_patterns.include?(pattern_digest)

    @hashed_patterns.add(pattern_digest)
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
        :SPO_Subject   => s,
        :SPO_Predicate => p,
        :SPO_Object    => o
      )
    else
      @patterns[type] = [SPO.new(
        :SPO_Subject   => s,
        :SPO_Predicate => p,
        :SPO_Object    => o
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
  def query_endpoint(endpoint_URL, mode = "exploratory", type = "")
    abort "must provide a type in any mode other than exploratory" if mode != "exploratory" and type.to_s.empty?
    sparql = SPARQL::Client.new(endpoint_URL, method: :post, headers: {
      "Accept" => "application/sparql-results+json"
    })
    if mode == "exploratory"
      #This first query asks for the types of objects inside the triplestore
      query = <<END
SELECT DISTINCT ?type
WHERE {
    ?subject a ?type .
}
END
      result = sparql.query(query)
    
    elsif mode == "fixed_subject"
      query = <<END
      
      SELECT DISTINCT ?predicate ?object_type
      WHERE {
          ?subject a <#{type}>.
          ?subject ?predicate ?object . 
          OPTIONAL{?object a ?object_type}.
      }
END
      $stderr.puts "query is:\n#{query}\n\n"
      result = sparql.query(query)

    elsif mode == "fixed_object"
      query = <<END
      
      SELECT DISTINCT ?predicate ?subject_type 
      WHERE {
          ?object a <#{type}>.
          ?subject ?predicate ?object . 
          OPTIONAL{?subject a ?subject_type}.
      }
END
      $stderr.puts "query is: #{endpoint_URL}\n#{query}\n\n"
      result = sparql.query(query)
    end
    
    result        
  end

  # Uses the query_endpoint method to get all the SPO patterns present in an endpoint, creating an index.
  #
  # @param endpoint_URL [String] the URL of the SPARQL endpoint to be indexed.
  # @return [patterns] A hash containing all the SPO patterns as SPO instances.
  def extract_patterns(endpoint_URLs_array)
    abort "the input must be an array of endpoint URLs" unless endpoint_URLs_array.is_a?(Array)
    @endpoint_patterns = Hash.new
    endpoint_URLs_array.each do |endpoint_URL|
      @patterns   = Hash.new
      @hashed_patterns = Set.new
      types_array = Array.new
      exploration_results = query_endpoint(endpoint_URL, "exploratory")
      $stderr.puts exploration_results.length.to_s + " types found"
      #The types are stored in an array so that they can be later explored individually in order
      exploration_results.each do |solution|
        next if solution[:type].to_s =~ /openlink/
        next if solution[:type].to_s =~ /w3\.org/
        
        if types_array.include? solution[:type].to_s
          next
        else
          types_array << solution[:type].to_s
        end
      end
                
      types_array.each do |type|
                  
        #This query asks for the types of objects and the predicates that interact with each of the types
        fsubject_results = query_endpoint(endpoint_URL, "fixed_subject", type)
        fsubject_results.each do |solution|
          next if solution[:object_type] =~ /rdf-schema/
          next if solution[:object_type] =~ /owl\#Ontology/
          
          # do a quick lookup to see if we already know this pattern
          next if in_database?(type,solution[:predicate],solution[:object_type]) # this will add it to teh database if it is not known
          add_triple_pattern(type, type, solution[:predicate], solution[:object_type])
          
        end
        fobject_results = query_endpoint(endpoint_URL, "fixed_object", type)
        fobject_results.each do |solution|
          # do a quick lookup to see if we already know this pattern
          next if in_database?(solution[:subject_type],solution[:predicate],type) # this will add it to teh database if it is not known
          add_triple_pattern(type, solution[:subject_type],solution[:predicate], type)
        end
      end
      @endpoint_patterns[endpoint_URL] = @patterns
    end
    @endpoint_patterns        
  end

  #Generates SHACL shapes corresponding to all the patterns from an endpoint and writes them to a file in turtle format.
  #
  # @param patterns_hash [Hash] The hash containing all the triple patterns from an endpoint as instances of SPO.
  # @param output_file [String] The name of the output file that will contain all the SHACL shapes. It is recommended to use .ttl as its extension.
  # @return [File] A file containing the SHACL shapes corresponding to all the SPO patterns given as input.
  def shacl_generator(patterns_hash, output_dir, mode)
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
    unless ["create", "append"].include?(mode.downcase)
      abort "The mode should be 'create' or 'append'"
    end
  
    file_mode = mode.downcase == "create" ? "w" : "a"
  
    patterns_hash.each do |url, patterns|
      begin
        uri = URI.parse(url)
        hostname = uri.host || "unknown_host"
        # Get the last non-empty segment of the path
        path_segment = uri.path.split('/').reject(&:empty?).last || "no_path"
        # Sanitize hostname and path segment
        sanitized_host = hostname.downcase.gsub(/[^a-z0-9]/, '_').squeeze('_')
        sanitized_path = path_segment.downcase.gsub(/[^a-z0-9]/, '_').squeeze('_')
        timestamp = Time.now.strftime("%Y%m%d")
        filename = "#{sanitized_host}_#{sanitized_path}_#{timestamp}.ttl"
      rescue URI::InvalidURIError
        puts "Invalid URL: #{url}. Skipping."
        next
      end
  
      output_path = File.join(output_dir, filename)
  
      File.open(output_path, file_mode) do |file|
        # Add prefixes if we're creating a new file
        if mode.downcase == "create"
          file.write <<~PREFIXES
            @prefix sh: <http://www.w3.org/ns/shacl#> .
            @prefix dcterms: <http://purl.org/dc/terms/> .
            @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
  
          PREFIXES
        end
  
        new_patterns_hash = Hash.new
  
        patterns.each do |key, value|
          value.each do |pattern|
            subj = pattern.SPO_Subject.to_s
            new_patterns_hash[subj] ||= []
            new_patterns_hash[subj] << pattern
          end
        end
  
        new_patterns_hash.each do |subject, patterns_array|
          puts "Processing shape for #{subject}"
          shape_intro = "<#{subject}Shape>\n\ta sh:NodeShape ;\n\tsh:targetClass <#{subject}> ;\n\tdcterms:source <#{url}> ;\n"
          file.write shape_intro
  
          patterns_array.each_with_index do |pattern, index|
            is_last = (index == patterns_array.length - 1)
            indent = "\t"
  
            if pattern.SPO_Object.nil?
              prop_text = "#{indent}sh:property [\n#{indent}\tsh:path <#{pattern.SPO_Predicate}> ;\n#{indent}]"
            else
              prop_text = "#{indent}sh:property [\n#{indent}\tsh:path <#{pattern.SPO_Predicate}> ;\n#{indent}\tsh:class <#{pattern.SPO_Object}> ;\n#{indent}]"
            end
  
            prop_text += is_last ? " .\n\n" : " ;\n"
            file.write prop_text
          end
        end
      end
    end
  end
end
