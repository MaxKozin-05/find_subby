class Project < ApplicationRecord
  belongs_to :profile
  has_many_attached :photos

  validates :title, presence: true
end
