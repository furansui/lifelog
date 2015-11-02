class CreateHealths < ActiveRecord::Migration
  def change
    create_table :healths do |t|
      t.datetime :logged_at
      t.float :value
      t.integer :health_category_id
      t.string :notes

      t.timestamps
    end
  end
end
