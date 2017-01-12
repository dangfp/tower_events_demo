class Todo < ApplicationRecord
  include Resourceable
  include Eventable

  acts_as_paranoid

  has_one :resource, as: :resourceable
  has_many :track, as: :trackable
  belongs_to :project
end
