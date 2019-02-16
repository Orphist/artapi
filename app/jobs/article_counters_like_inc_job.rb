class ArticleCountersLikeIncJob < ActiveJob::Base

  def perform(article_id)
    ::ArticleCountersBuffer.new(article_id: article_id).like_increment
  end

end