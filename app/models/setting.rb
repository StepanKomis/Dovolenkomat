class Setting < ApplicationRecord
  belongs_to :updated_by, class_name: "User", optional: true

  validates :max_concurrent_vacationers, presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  def self.current
    first || create!(max_concurrent_vacationers: 2)
  end
end
