module ItemTypeValidatable
  include ApplicationHelper
  extend ActiveSupport::Concern

  TYPE_REQUIRED_VALUES = %w(Collection Dataset MovingImage StillImage Interactive Resource Software Sound Text)

  included do

    after_validation :set_validation_cache

    validates_presence_of :collection, message: ' must be selected'
    validates_presence_of :dcterms_temporal, :dcterms_spatial
    validate :dcterms_temporal_characters
    validate :dcterms_type_required_value
    validate :url_in_dc_identifier
    validate :url_in_dcterms_is_shown_at

  end

  private

  def dcterms_temporal_characters
    unless dcterms_temporal
      errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    dcterms_temporal.each do |v|
      if v =~ /([^0-9\/-])/
        errors.add(:dcterms_temporal, I18n.t('activerecord.errors.messages.temporal_invalid_character'))
        return
      end
    end
  end

  def dcterms_type_required_value
    unless dcterms_type
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.blank'))
      return
    end
    if (dcterms_type & TYPE_REQUIRED_VALUES).empty?
      errors.add(:dcterms_type, I18n.t('activerecord.errors.messages.type_required_value'))
    end
  end

  # def has_rights_information
  #   if dc_right.empty? and dcterms_rights_holder.empty?
  #     errors.add(:entity, I18n.t('activerecord.errors.messages.no_rights_information'))
  #   end
  # end

  def url_in_dc_identifier
    dc_identifier.each do |v|
      unless valid_url? v
        errors.add(:dc_identifier, I18n.t('activerecord.errors.messages.invalid_url_provided'))
        return
      end
    end
  end

  def url_in_dcterms_is_shown_at
    dcterms_is_shown_at.each do |v|
      unless valid_url? v
        errors.add(:dcterms_is_shown_at, I18n.t('activerecord.errors.messages.invalid_url_provided'))
        return
      end
    end
  end

  def set_validation_cache
    self.valid_item = errors.empty?
  end

end