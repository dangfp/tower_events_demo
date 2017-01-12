class Team < ApplicationRecord
  include Resourceable
  include Eventable

  has_one :resource, as: :resourceable
  has_many :track, as: :trackable

  after_create do |team|
    RequestStore.store[:current_team] = team
  end
end
