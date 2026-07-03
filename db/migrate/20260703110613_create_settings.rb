class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.integer :max_concurrent_vacationers, null: false, default: 2
      t.references :updated_by, foreign_key: { to_table: :users }, null: true
      t.timestamps
    end
  end
end
