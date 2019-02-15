class ArticleCountersBuffer < Valuable
  has_value :article_id

  def like_increment
    ArticleCounter.create!(article_id: article_id, like: 1, dislike: 0)
  end

  def dislike_increment
    ArticleCounter.create!(article_id: article_id, like: 0, dislike: 1)
  end

end
