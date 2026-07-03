class SplitVacationRequestDecisionStatus < ActiveRecord::Migration[8.1]
  def change
    remove_column :vacation_requests, :status, :integer

    add_column :vacation_requests, :hr_status, :integer, null: false, default: 0
    add_reference :vacation_requests, :hr_decided_by, foreign_key: { to_table: :users }, null: true
    add_column :vacation_requests, :hr_decided_at, :datetime
    add_column :vacation_requests, :hr_comment, :string

    add_column :vacation_requests, :head_status, :integer, null: false, default: 0
    add_reference :vacation_requests, :head_decided_by, foreign_key: { to_table: :users }, null: true
    add_column :vacation_requests, :head_decided_at, :datetime
    add_column :vacation_requests, :head_comment, :string
  end
end
