class CreateArticleCounters < ActiveRecord::Migration[5.2]
  def change
    create_table :article_counters do |t|
      t.bigint  :article_id
      t.integer :like
      t.integer :dislike

      t.timestamp :created_at
    end
  end
end
