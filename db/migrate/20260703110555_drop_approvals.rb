class DropApprovals < ActiveRecord::Migration[8.1]
  def change
    drop_table :approvals do |t|
      t.references :vacation_request, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.integer :stage
      t.integer :decision
      t.string :comment
      t.timestamps
    end
  end
end
