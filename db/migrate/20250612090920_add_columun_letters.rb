class AddStarToLetters < ActiveRecord::Migration[7.2]
  def change
    add_column :letters, :star, :integer, default: 0, null: false
  end
end
