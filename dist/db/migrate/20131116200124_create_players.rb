class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.boolean :playing
      t.integer :level

      t.timestamps
    end
  end
end
