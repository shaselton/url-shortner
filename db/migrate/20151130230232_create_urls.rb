class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :original, index: true
      t.string :new
      t.integer :clicks

      t.timestamps null: false
    end
  end
end
