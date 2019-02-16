class ArticleCounterSubscriber

  def article_counter_flush_buffer(article_counter_id)
    ArticleCountersFlushJob.perform_later(article_counter_id)
  end

end
