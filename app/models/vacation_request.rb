class VacationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :hr_decided_by, class_name: "User", optional: true
  belongs_to :head_decided_by, class_name: "User", optional: true

  enum :hr_status, { pending: 0, approved: 1, rejected: 2 }, prefix: true
  enum :head_status, { pending: 0, approved: 1, rejected: 2 }, prefix: true

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  def status
    return "rejected" if hr_status_rejected? || head_status_rejected?
    return "approved" if head_status_approved?
    return "hr_approved" if hr_status_approved?
    "pending"
  end

  def pending?
    status == "pending"
  end

  def hr_approved?
    status == "hr_approved"
  end

  def approved?
    status == "approved"
  end

  def rejected?
    status == "rejected"
  end

  def record_hr_decision!(by:, approved:, comment: nil)
    update!(
      hr_status: approved ? :approved : :rejected,
      hr_decided_by: by,
      hr_decided_at: Time.current,
      hr_comment: comment
    )
  end

  def record_head_decision!(by:, approved:, comment: nil)
    unless approved
      return update!(
        head_status: :rejected,
        head_decided_by: by,
        head_decided_at: Time.current,
        head_comment: comment
      )
    end

    if self.class.would_exceed_capacity?(start_date, end_date, excluding: self)
      errors.add(:base, "Cannot approve: would exceed the maximum of " \
                         "#{Setting.current.max_concurrent_vacationers} concurrent vacationers")
      return false
    end

    transaction do
      if hr_status_pending?
        update!(hr_status: :approved, hr_decided_by: by, hr_decided_at: Time.current,
                hr_comment: "Auto-approved (head override)")
      end
      update!(head_status: :approved, head_decided_by: by,
              head_decided_at: Time.current, head_comment: comment)
    end
    true
  end

  def self.would_exceed_capacity?(start_date, end_date, excluding: nil)
    return false if start_date.blank? || end_date.blank?

    limit = Setting.current.max_concurrent_vacationers
    scope = head_status_approved
    scope = scope.where.not(id: excluding.id) if excluding&.persisted?

    (start_date..end_date).any? do |date|
      scope.where("start_date <= ? AND end_date >= ?", date, date).count >= limit
    end
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end
end
