module Resourceable
  extend ActiveSupport::Concern

  included do
    after_create do |obj|
      Resource.create!(resourceable: obj)
    end
  end
end
