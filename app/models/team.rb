class Team < ApplicationRecord
  include Resourceable
  include Eventable

  has_one :resource, as: :resourceable

  after_create do |team|
    RequestStore.store[:current_team] = team
  end
end
