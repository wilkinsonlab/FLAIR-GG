
class Discoverable
  @@alldiscoverables = []

  attr_accessor :source, :contact, :resource, :title, :type, :icon, :typetag

  def initialize(source:, resource:, title:, type:, icon:, typetag:)
    @source = source   # this is the vcard url
    @contact = source.gsub(/^https?\/\//, "")  # get rid of the http part of the url
    @resource = resource  # this is the address of the resource itself
    @title = title
    @type = type
    @icon = icon
    @typetag = typetag
    @@alldiscoverables << self
  end

  def self.find_by_typetag(typetag:)
    @@alldiscoverables.select { |d| d.typetag == typetag }
  end

  def self.find_by_type(type:)
    @@alldiscoverables.select { |d| d.type == type }
  end

  def self.find_by_source(source:)
    @@alldiscoverables.select { |d| d.source == source }
  end

  def self.all_sources
    sources = @@alldiscoverables.map(&:contact)
    sources.uniq.sort
  end

  def self.all
    @@alldisoverables
  end

  # we need to avoid duplicates in the @@alldiscoverables
  def self.create_or_retrieve(source:, resource:, title:, type:, icon:, typetag:)
    @@alldiscoverables.each do |d|
      return d if d.source == source && d.resource == resource  # this is probably redundant, unless another site is pointing to your resource
    end
    Discoverable.new(source: source, resource: resource, title: title, type: type, icon: icon, typetag: typetag)
  end
end
