class User < ApplicationRecord
  has_secure_password

  enum :role, { employee: 0, hr: 1, head: 2 }

  has_many :vacation_requests, dependent: :destroy
end
