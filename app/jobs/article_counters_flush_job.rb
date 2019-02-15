class ArticleCountersFlushJob < ActiveJob::Base

  def perform(article_counter_last_id = edge_buffer_article_counter_id)
    ::ArticleCountersUpdater.new(article_counter_last_id: article_counter_last_id).flush_buffer!
  end

  def edge_buffer_article_counter_id
    ArticleCounter.last.id
  end

end