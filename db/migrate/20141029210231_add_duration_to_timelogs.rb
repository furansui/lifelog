class AddDurationToTimelogs < ActiveRecord::Migration
  def change
    add_column :timelogs, :duration, :integer
  end
end
