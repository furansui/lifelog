class AddCategoryRefToTimelogs < ActiveRecord::Migration
  def change
    add_reference :timelogs, :category, index: true
  end
end
