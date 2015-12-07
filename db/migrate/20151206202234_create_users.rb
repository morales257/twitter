class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      #this part of the block creates 2 columns
      t.string :name
      t.string :email
      #this creates columns to record created and updated times
      t.timestamps null: false
    end
  end
end
