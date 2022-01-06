class Item < ApplicationRecord
  validates :quantity, :numericality => {:greater_than_or_equal_to => 0}
  validates_presence_of :title, :quantity
  validates_uniqueness_of :title

  belongs_to :collection, :optional => true
end
