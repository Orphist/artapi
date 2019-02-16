class ArticleCountersUpdater < Valuable
  has_value :article_counter_last_id

  def flush_buffer!
    process_buffer!
    clean_buffer!
  end

  private

  def counters_grouped_by_article_id
    @counters_grouped_by_article_id ||= ArticleCounter.where('id <= ?', article_counter_last_id).
        select('article_id, SUM("like") likes_count, SUM("dislike") dislikes_count').
        group(:article_id)
  end

  def process_buffer!
    return if counters_grouped_by_article_id.blank?
    stnmt = <<~SQL
      UPDATE articles
      SET likes_counter    = likes_counter    + articles_update.likes_count,
          dislikes_counter = dislikes_counter + articles_update.dislikes_count
      FROM
      (
            SELECT
                UNNEST(ARRAY[#{counters_grouped_by_article_id.map(&:article_id).join(',')}    ]) article_id,
                UNNEST(ARRAY[#{counters_grouped_by_article_id.map(&:likes_count).join(',')}   ]) likes_count,
                UNNEST(ARRAY[#{counters_grouped_by_article_id.map(&:dislikes_count).join(',')}]) dislikes_count
      ) articles_update
      WHERE articles.id = articles_update.article_id;
    SQL
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.execute stnmt
    end
  end

  def clean_buffer!
    stnmt = <<~SQL
      DELETE FROM article_counters WHERE id <= #{article_counter_last_id};
    SQL
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.execute stnmt
    end
  end
end