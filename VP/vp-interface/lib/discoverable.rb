require_relative "ontologyservers/bioregistry"
require_relative  "ontologyservers/identifiers"
require_relative  "ontologyservers/ebi_ontology"
require_relative  "ontologyservers/ebi_ontology_v3"
require_relative  "ontologyservers/ontobee"
require_relative  "ontologyservers/etsi"
require_relative  "ontologyservers/bio2rdf"
require_relative  "ontologyservers/ncbo"
require_relative  "ontologyservers/schema"
require_relative  "ontologyservers/edam"

require_relative  "wordcloud"
require_relative  "cache"
require_relative  "metadata_functions"

@@alldisoverables = []
class Discoverable
  attr_accessor :contact, :resource, :title, :type, :icon

  def initialize(contact:, resource:, title:, type:, icon:)
    @contact = contact
    @resource = resource
    @title = title
    @type = type
    @icon = icon
    @@alldiscoverables << self
  end

  def self.find_by_type(type:)
    @@alldiscoverables.select {|d| d.type == type}
  end

    # we need to avoid duplicates in the @@alldiscoverables
  def self.create_or_retrieve(contact:, resource:, title:, type:, icon:)
    @@alldiscoverables.each do |d|
      return d if d.contact == contact and d.type == type
    end
    Discoverable.new(contact: contact, resource: resource, title: title, type: type, icon: icon)
  end
end
