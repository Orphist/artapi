class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :description
      t.bigint :likes_counter
      t.bigint :dislikes_counter
    end
  end
end
