class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    #we expect to retrieve all microposts associated with a given user id in
    #reverse order of creation so we add an index to the user_id and created_at columns
    #by including both columns as an array we createa multiple key index ->
    #the active record uses both keys at the same time
    add_index :microposts, [:user_id, :created_at]
  end
end
