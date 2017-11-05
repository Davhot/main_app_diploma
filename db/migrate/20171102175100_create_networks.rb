class CreateNetworks < ActiveRecord::Migration[5.0]
  def change
    create_table :networks do |t|
      t.string :name
      t.float :bytes_in
      t.float :bytes_out
      t.float :packets_in
      t.float :packets_out
      t.references :system_metric, foreign_key: true

      t.timestamps
    end
  end
end
