class AddShortcutToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :shortcut, :string
  end
end
