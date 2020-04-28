class Advertisement < ActiveRecord::Base
  include PublishableModel
  validates :weight, numericality: { greater_than: 0 }
end
