class CreateShortenedUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :shortened_urls do |t|
      t.string :short_url, null: false, index: {unique: true}
      t.string :long_url, null: false
      t.string :user_id, null: false, index: {unique: true}

      t.timestamps
    end
  end
end
