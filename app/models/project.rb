class Project < ApplicationRecord
  include Resourceable
  include Eventable

  acts_as_paranoid

  has_one :resource, as: :resourceable
end
