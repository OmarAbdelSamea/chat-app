class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :number, unique: true, null: false
      t.text :content, null: false
      t.references :chat, foreign_key: true

      t.timestamps
    end
  end
end
