class ChangeUserIdInShortenedUrls < ActiveRecord::Migration[5.2]
  def change
    # removing unique constraint
    remove_index :shortened_urls, :user_id
    add_index :shortened_urls, :user_id
  end
end
