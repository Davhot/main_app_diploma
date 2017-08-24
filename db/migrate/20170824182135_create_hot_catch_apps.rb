class CreateHotCatchApps < ActiveRecord::Migration[5.0]
  def change
    create_table :hot_catch_apps do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
