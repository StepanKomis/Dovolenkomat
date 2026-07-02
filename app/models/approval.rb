class Approval < ApplicationRecord
  belongs_to :vacation_request
  belongs_to :approver, class_name: "User"
end
