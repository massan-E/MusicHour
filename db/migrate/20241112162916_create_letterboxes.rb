class CreateLetterboxes < ActiveRecord::Migration[8.0]
  def change
    create_table :letterboxes do |t|
      t.string :title

      t.timestamps
    end
  end
end
