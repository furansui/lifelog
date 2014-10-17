class CreateTimelogs < ActiveRecord::Migration
  def change
    create_table :timelogs do |t|
      t.datetime :time
      t.string :event

      t.timestamps
    end
  end
end
