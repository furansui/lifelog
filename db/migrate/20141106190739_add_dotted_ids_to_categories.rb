class AddDottedIdsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :dotted_ids, :string
  end
end
