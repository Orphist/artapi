class Api::V1::ArticlesController < ::Api::BaseController

  def index
    articles = Article.all
    paginate articles.count,
             max_limit_per_page,
             allow_render: false,
             raise_errors: true do |limit, offset|
      render_response(200, { articles: present_index(articles.limit(limit).offset(offset)) } )
    end
  end

  def like
    article_counters_service.like_increment
  end

  def dislike
    article_counters_service.dislike_increment
  end

  private

  def permited_params
    params.permit(:id, :limit)
  end

  def article_counters_service
    ensure_requested_article_exists
    ::ArticleCountersBuffer.new(article_id: permited_params[:id])
  end

  def ensure_requested_article_exists
    Article.find(permited_params[:id])
  end

  def present_index(articles)
    ArticleSerializer.new(articles).to_hash
  end
end