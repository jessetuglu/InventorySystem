class Collection < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :items

  def as_json(options={})
    super(:include => :items)
  end
end
