class CreateMainHotCatchLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :main_hot_catch_logs do |t|
      t.text :log_data, null: false
      t.integer :count_log, null: false, default: 1
      t.integer :id_log_origin_app, null: false
      t.string :name_app, null: false
      t.string :from_log, null: false
      t.string :status
      t.references :hot_catch_app, index: true, foreign_key: true

      t.timestamps

      t.index [:id_log_origin_app, :name_app], unique: true
    end
  end
end
