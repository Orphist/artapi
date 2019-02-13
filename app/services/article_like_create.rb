module Services
  class ArticleLikeCreate

    def initialize()
    end

    def call
      create_post
      if post_persisted
        context.post_id = post.id
      else
        context.fail!(errors: post.errors.full_messages + call_trace)
      end
    end

    private

    def create_like
      Article.transaction do
        @post = Article.new(title: context.title, content: context.content,
                          user_id: context.user_id, ip_addr: context.ip_addr)
        @post_persisted = post.save
      end
    end

  end
end