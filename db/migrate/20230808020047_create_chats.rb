class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.json :history
      t.string :q_and_a, array: true, default: []

      t.timestamps
    end
  end
end
