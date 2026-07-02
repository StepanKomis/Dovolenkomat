class CreateVacationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :vacation_requests do |t|
      t.date :start_date
      t.date :end_date
      t.text :reason
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
