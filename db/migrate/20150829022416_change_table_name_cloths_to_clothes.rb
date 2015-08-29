class ChangeTableNameClothsToClothes < ActiveRecord::Migration
  def change
    rename_table :cloths, :clothes
  end
end
