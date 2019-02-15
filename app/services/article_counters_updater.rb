class ArticleCountersUpdater < Valuable
  has_value :article_counter_last_id

  def flush_buffer!
    process_buffer!
    clean_buffer!
  end

  private

  def counters_grouped_by_article_id
    ArticleCounter.where('id <= ?', article_counter_last_id).
        select('article_id, SUM("like") likes_count, SUM("dislike") dislikes_count').
        group(:article_id)
  end

  def process_buffer!
    counters_grouped_by_article_id.each do |rel|
      Article.find(rel.article_id).update(likes_counter: rel.likes_count, dislikes_counter: rel.dislikes_count)
    end
  end

  def clean_buffer!
    ArticleCounter.where('id <= ?', article_counter_last_id).destroy_all
  end
end