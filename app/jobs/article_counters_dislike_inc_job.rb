class ArticleCountersDislikeIncJob < ActiveJob::Base

  def perform(article_id)
    ::ArticleCountersBuffer.new(article_id: article_id).dislike_increment
  end

end