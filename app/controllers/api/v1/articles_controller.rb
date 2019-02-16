class Api::V1::ArticlesController < ::Api::BaseController
  before_action :ensure_requested_article_exists, only: [:like, :dislike]

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
    ::ArticleCountersLikeIncJob.perform_later(permited_params[:id])
  end

  def dislike
    ::ArticleCountersDislikeIncJob.perform_later(permited_params[:id])
  end

  private

  def permited_params
    params.permit(:id, :limit)
  end

  def ensure_requested_article_exists
    Article.find(permited_params[:id])
  end

  def present_index(articles)
    ArticleSerializer.new(articles).to_hash
  end
end