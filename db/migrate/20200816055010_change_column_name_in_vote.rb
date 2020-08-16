class ChangeColumnNameInVote < ActiveRecord::Migration[5.2]
  def change
    rename_column :votes, :postive, :positive
  end
end
