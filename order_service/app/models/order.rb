class Order < ApplicationRecord

  has_many :line_items, dependent: :destroy


  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[cart pending completed cancelled] }
end
