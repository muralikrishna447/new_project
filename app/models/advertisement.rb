class Advertisement < ApplicationRecord
  include PublishableModel
  validates :weight, numericality: { greater_than: 0 }
end
