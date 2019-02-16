class ArticleCounter < ApplicationRecord
  MAX_BUFFER_SIZE ||= 200
  MAX_BUFFER_AGE  ||= 10.seconds

  include Wisper::Publisher

  after_create_commit :check_buffer

  def check_buffer
    deliver_article_counters_msg if flush_buffer?
  end

  private

  def flush_buffer?
    buffer_oversize? || buffer_overtime?
  end

  def buffer_oversize?
    ArticleCounter.count > MAX_BUFFER_SIZE
  end

  def buffer_overtime?
    ArticleCounter.minimum(:created_at) < (Time.now - MAX_BUFFER_AGE)
  end

  def deliver_article_counters_msg
    broadcast(:article_counter_flush_buffer, self.id)
  end
end
