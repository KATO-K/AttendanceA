class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.string :name
      t.string :kind
      t.integer :number

      t.timestamps
    end
  end
end
