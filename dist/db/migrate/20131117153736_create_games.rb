class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :level
      t.references :winner
      t.references :player1
      t.references :player2

      t.timestamps
    end
    add_index :games, :player1_id
    add_index :games, :player2_id
    add_index :games, :winner_id
  end
end
