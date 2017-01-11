module Resourceable
  extend ActiveSupport::Concern

  included do
    after_create do |obj|
      Resource.create!(resourceable_id: obj.id, resourceable_type: obj.class.name)
    end
  end
end
