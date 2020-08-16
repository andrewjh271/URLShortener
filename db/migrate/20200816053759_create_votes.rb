class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.boolean :postive
      t.boolean :negative
      t.integer :user_id, null: false, index: true
      t.integer :url_id, null: false, index: true

      t.timestamps
    end
  end
end
