class Collection < ActiveRecord::Base
  include Slugged

  has_many :items, dependent: :destroy, counter_cache: true
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository

  validates_presence_of :display_title

end
