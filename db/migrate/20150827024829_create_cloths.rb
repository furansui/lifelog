class CreateCloths < ActiveRecord::Migration
  def change
    create_table :cloths do |t|
      t.string :name
      t.string :brand
      t.text :wear

      t.timestamps
    end
  end
end
