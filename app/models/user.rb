class User < ApplicationRecord
  has_secure_password

  has_many :accesses
  has_many :resources, through: :accesses
end
