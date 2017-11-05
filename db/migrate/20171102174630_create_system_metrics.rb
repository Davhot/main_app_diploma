class CreateSystemMetrics < ActiveRecord::Migration[5.0]
  def change
    create_table :system_metrics do |t|
      t.float :cpu_average_minute
      t.integer :memory_size
      t.integer :memory_used
      t.integer :swap_size
      t.integer :swap_used
      t.integer :discriptors_max
      t.integer :descriptors_used
      t.datetime :get_time
      t.references :hot_catch_app, index: true, foreign_key: true

      t.timestamps
    end
  end
end
