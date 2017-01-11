class Team < ApplicationRecord
  include Resourceable
  include Eventable

  has_one :resource, as: :resourceable
end
