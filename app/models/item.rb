class Item < ActiveRecord::Base
  include ApplicationHelper
  include Slugged
  include MetadataHelper
  include IndexFilterable
  include ItemTypeValidatable
  include GeospatialIndexable
  include Portable

  belongs_to :collection, counter_cache: true
  has_one :repository, through: :collection
  has_many :batch_items

  validates_uniqueness_of :slug, scope: :collection_id
  validates_presence_of :collection

  scope :updated_since, lambda { |since| where('updated_at >= ?', since) }

  has_paper_trail class_name: 'ItemVersion'

  # after_save :check_for_thumbnail
  before_save :set_record_id

  searchable do

    string :slug, stored: true
    string :record_id, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ''
    end

    integer :collection_id do
      collection.id
    end

    integer :repository_id do
      repository.id
    end

    string :collection_slug, stored: true do
      collection.slug
    end

    string :repository_slug, stored: true do
      repository.slug
    end

    string :collection_name, stored: true, multiple: true do
      collection_titles
    end

    string :repository_name, stored: true, multiple: true do
      repository_titles
    end

    string :portals, multiple: true do
      portal_codes
    end

    string :portal_names, stored: true, multiple: true do
      portal_names
    end

    boolean :dpla
    boolean :public
    boolean :valid_item

    string :valid_item, stored: true do
      valid_item ? 'Yes' : 'No'
    end

    string :display, stored: true do
      display? ? 'Yes' : 'No'
    end

    string :dpla, stored: true do
      dpla ? 'Yes' : 'No'
    end
    string :public, stored: true do
      public ? 'Yes' : 'No'
    end

    # *_display (not indexed, stored, multivalued)
    string :dcterms_provenance,             as: 'dcterms_provenance_display',             multiple: true
    string :dcterms_title,                  as: 'dcterms_title_display',                  multiple: true
    string :dcterms_creator,                as: 'dcterms_creator_display',                multiple: true
    string :dcterms_contributor,            as: 'dcterms_contributor_display',            multiple: true
    string :dcterms_subject,                as: 'dcterms_subject_display',                multiple: true
    string :dcterms_description,            as: 'dcterms_description_display',            multiple: true
    string :dcterms_publisher,              as: 'dcterms_publisher_display',              multiple: true
    string :edm_is_shown_at,                as: 'edm_is_shown_at_display',                multiple: true
    string :edm_is_shown_by,                as: 'edm_is_shown_by_display',                multiple: true
    string :dcterms_identifier,             as: 'dcterms_identifier_display',             multiple: true
    string :dc_date,                        as: 'dc_date_display',                        multiple: true
    string :dcterms_temporal,               as: 'dcterms_temporal_display',               multiple: true
    string :dcterms_spatial,                as: 'dcterms_spatial_display',                multiple: true
    string :dc_format,                      as: 'dc_format_display',                      multiple: true
    string :dcterms_is_part_of,             as: 'dcterms_is_part_of_display',             multiple: true
    string :dc_right,                       as: 'dc_right_display',                       multiple: true
    string :dcterms_rights_holder,          as: 'dcterms_rights_holder_display',          multiple: true
    string :dcterms_bibliographic_citation, as: 'dcterms_bibliographic_citation_display', multiple: true
    string :dlg_local_right,                as: 'dlg_local_right_display',                multiple: true
    string :dlg_subject_personal,           as: 'dlg_subject_personal_display',           multiple: true
    string :dc_relation,                    as: 'dc_relation_display',                    multiple: true
    string :dcterms_type,                   as: 'dcterms_type_display',                   multiple: true
    string :dcterms_medium,                 as: 'dcterms_medium_display',                 multiple: true
    string :dcterms_extent,                 as: 'dcterms_extent_display',                 multiple: true
    string :dcterms_language,               as: 'dcterms_language_display',               multiple: true

    # Primary Search Fields (multivalued, indexed, stemming/tokenized)
    text :dc_date
    text :dcterms_title
    text :dcterms_creator
    text :dcterms_contributor
    text :dcterms_subject
    text :dcterms_description
    text :dcterms_publisher
    text :dcterms_temporal
    text :dcterms_spatial
    text :dcterms_is_part_of
    text :edm_is_shown_at
    text :edm_is_shown_by
    text :dcterms_identifier
    text :dcterms_rights_holder
    text :dlg_subject_personal

    # special indexing for url fields - now set via copyFields in solr config
    # string :dcterms_identifier, as: 'dcterms_identifier_url', multiple: true
    # string :edm_is_shown_at, as: 'edm_is_shown_at_url', multiple: true

    string :title, as: 'title' do
      dcterms_title.first ? dcterms_title.first : slug
    end

    # required for Blacklight - a single valued format field
    string :format, as: 'format' do
      dc_format.first ? dc_format.first : ''
    end

    # sort fields
    string :collection_sort, as: 'collection_sort' do
      collection.title.downcase.gsub(/^(an?|the)\b/, '')
    end

    string :title_sort, as: 'title_sort' do
      dcterms_title.first ? dcterms_title.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

    string :creator_sort, as: 'creator_sort' do
      dcterms_creator.first ? dcterms_creator.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

    integer :year, as: 'year', trie: true do
      DateIndexer.new.get_sort_date(dc_date)
    end

    # facet fields
    integer :year_facet, multiple: true, trie: true, as: 'year_facet' do
      DateIndexer.new.get_valid_years_for(dc_date, self)
    end

    # datetimes
    time :created_at, stored: true, trie: true
    time :updated_at, stored: true, trie: true

    # spatial stuff
    string :coordinates, as: 'coordinates', multiple: true
    string :geojson, as: 'geojson', multiple: true
    string :placename, as: 'placename', multiple: true

  end

  def self.index_query_fields
    %w(collection_id public valid_item).freeze
  end

  def display?
    repository.public && collection.public && public
  end

  def facet_years
    all_years = []
    dc_date.each do |date|
      all_years << date.scan(/[0-2][0-9][0-9][0-9]/)
    end
    all_years.flatten.uniq
  end

  def collection_titles
    (other_collection_titles << collection.title).reverse
  end

  def repository_titles
    (other_repository_titles << repository.title).reverse
  end

  def title
    dcterms_title.first ? dcterms_title.first.strip : 'No Title'
  end

  def to_xml(options = {})
    default_options = {
      dasherize: false,
      except: [
        :collection_id,
        :record_id,
        :other_collections,
        :valid_item,
        :has_thumbnail,
        :created_at,
        :updated_at
      ],
      include: {
        other_colls: {
          skip_types: true,
          only: [:record_id]
        },
        collection: {
          only: [:record_id]
        },
        portals: {
          only: [:code]
        }
      }
    }
    super(options.merge!(default_options))
  end

  def to_batch_item

    attributes = self.attributes.except(
      'id',
      'created_at',
      'updated_at',
      'valid_item'
    )

    batch_item = BatchItem.new attributes
    batch_item.item = self
    batch_item

  end

  def other_collection_titles
    other_colls.map(&:title)
  end

  def other_colls
    Collection.find(other_collections)
  end

  private

  def set_record_id
    self.record_id = "#{repository.slug}_#{collection.slug}_#{slug}".downcase
  end

  def other_repository_titles
    Collection.find(other_collections).map(&:repository_title)
  end

  # def date_facet
  #
  #   # check if dc_date contains a well-formatted date range
  #   dc_date.each do |date|
  #
  #     if date.scan(/\//).size == 1
  #
  #       # we likely have a date range here
  #       # try and get two dates, ISO style
  #       iso_dates = date.scan(/[0-2][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)
  #       if iso_dates.size == 2
  #
  #         # we have a likely date range!
  #         # so now we want to get all years in between....
  #         iso_dates.map { |d| Date.strptime(s, "%Y-%m-%d") }.sort
  #
  #
  #       end
  #     end
  #   end
  #
  # end

end

