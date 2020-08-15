class AddPremiumToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :premium, :boolean, default: false

    User.update_all('premium = false')
  end
end
