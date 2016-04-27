class Batch < ActiveRecord::Base

  belongs_to :user
  has_many :batch_items, dependent: :destroy

  scope :committed, -> { where('committed_at IS NOT NULL' ) }
  scope :pending, -> { where('committed_at IS NULL' ) }

  validates_presence_of :user, :name

  searchable do

    text :name
    text :notes

    integer :user_id

    time :committed_at
    time :updated_at
    time :created_at

  end

  def committed?
    !!committed_at
  end

  def commit
    self.committed_at = Time.now
    batch_items.map do |bi|
      i = bi.commit
      i.save
      {batch_item: bi, item: i }
    end
  end

end

