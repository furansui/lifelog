class CreateHealthCategories < ActiveRecord::Migration
  def change
    create_table :health_categories do |t|
      t.string :name
      t.string :unit

      t.timestamps
    end
  end
end
