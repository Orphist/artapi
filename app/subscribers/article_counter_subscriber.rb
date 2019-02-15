class ArticleCounterSubscriber

  def article_counter_flush_buffer(article_counter_id)
    # ::ArticleCountersUpdater.new(article_counter_last_id: article_counter_id).flush_buffer!
    ArticleCountersFlushJob.perform_later(article_counter_id)
  end

end
