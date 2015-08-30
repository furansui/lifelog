class AddBoughtToClothes < ActiveRecord::Migration
  def change
    add_column :clothes, :bought, :date
  end
end
