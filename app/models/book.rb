class Book < ApplicationRecord
  validates :name, presence: true, length: { maximum: 32 }, uniqueness: true
end
