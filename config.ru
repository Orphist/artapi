# This file is used by Rack-based servers to start the application.

# require_relative 'config/environment'
#
# run Rails.application


# **************************
# **************************
# **************************
# require "roda"
#
# class App < Roda
#
#   plugin :all_verbs
#   plugin :default_headers, {"Content-Type" => ""}
#   # plugin :delete_empty_headers
#   plugin :request_headers
#   plugin :not_allowed
#
#   route do |r|
#     # # GET / request
#     # r.root do
#     #   r.redirect "/articles"
#     # end
#
#     # /articles branch
#     r.on "articles" do
#
#       # GET /articles/index request
#       r.get "index" do
#         articles = Article.all
#         paginate articles.count,
#                  10,
#                  allow_render: false,
#                  raise_errors: true do |limit, offset|
#           binding.pry
#           json_body = { articles: present_index(articles.limit(limit).offset(offset)) }
#           r.halt response.finish_with_body(json_body)
#         end
#       end
#
#       # /articles request
#       r.is String do |id|
#         # PUT /articles/{id}/likes request
#         r.post 'likes' do
#           ensure_requested_article_exists
#           ::ArticleCountersLikeIncJob.perform_later(id.to_i)
#         end
#
#         # PUT /articles/{id}/dislikes request
#         r.post 'dislikes' do
#           ensure_requested_article_exists
#           ::ArticleCountersDislikeIncJob.perform_later(id.to_i)
#         end
#         # response.headers.update(info.headers)
#         # no_content!
#         r.halt response.finish_with_body({})
#       end
#     end
#   end
#
#   def ensure_requested_article_exists
#     Article.find(permited_params[:id])
#   rescue Exception=>exception
#     case exception
#       when ActiveRecord::RecordNotFound
#         # render_response(404, {})
#         r.halt response.finish_with_body({})
#       else
#         logger.error 'Error 500 is rendered by Api::BaseController:'
#         logger.error exception.message
#         exception.backtrace.each do |line|
#           logger.error line
#         end
#         #ToDo: send it to Rollbar, Prometheus etc
#         # render_response(500, {})
#         r.halt response.finish_with_body({})
#     end
#   end
#
#   def present_index(articles)
#     ArticleSerializer.new(articles).to_hash
#   end
#
# end
#
# run App.freeze.app

# ***********************************************************************
# ***********************************************************************
# ***********************************************************************
# rack-api

require "rack/api"

require 'active_record/rack'
# Middleware below this point may require database access:
use ActiveRecord::Rack::ConnectionManagement

require "active_record/railtie"
require "active_job/railtie"
require 'wisper'
require 'valuable'
require 'fast_jsonapi'

%w(models services jobs serializers subscribers).each do |path|
  Dir[File.join('app',path,'*')].select{|f| File.file?(f)}.each do |file|
    require_relative file
  end
end

ActiveRecord::Base.establish_connection(YAML.load_file(File.join 'config', 'database.yml')['production'])

require 'sequel'
require 'rack/with_sequel'

db = Sequel.connect("postgresql://postgres:postgres@localhost:5432/artapi_prod")
db.freeze
use Rack::WithSequel, db: db

class CatchErrorsWithSequel < Rack::WithSequel
  ERRORS = [Sequel::DatabaseConnectionError, Sequel::PoolTimeout]

  def call(env)
    super
  rescue *ERRORS
    [503, {}, ["database connection error"]]
  end
end

use CatchErrorsWithSequel

Rack::API.app do

  prefix 'api'

  # version :v1 do
    get "articles/index(.:format)" do
      # requested_from, requested_to = nil, nil
      # if request.headers['Range'] =~ /(\d+)-(\d*)/
      #   requested_from, requested_to = $1.to_i, ($2.present? ? $2.to_i : Float::INFINITY)
      # end
      #   stnmt = <<~SQL
      #     select * from articles LIMIT 100 OFFSET #{rand(1..9800)};
      #   SQL
      #   articles = ActiveRecord::Base.connection_pool.with_connection do |connection|
      #     connection.execute stnmt
      #   end
      #   articles = Article.limit(100).offset(rand(1..9800))
        articles = db["select * from articles limit 100 offset #{rand(1..9800)}"].all
        json_body = { articles: articles }
        render status: 200, json: json_body.to_json
      # end
    end

    put "articles/:id/like(.:format)" do
      # Article.find(params[:id])
      if db[:articles].where(id: params[:id]).all.empty?
        render status: 404, json: {}
      end
      ::ArticleCountersLikeIncJob.perform_later(params[:id])
    end

    put "articles/:id/dislike(.:format)" do
      # Article.find(params[:id])
      if db[:articles].where(id: params[:id]).all.empty?
        render status: 404, json: {}
      end
      ::ArticleCountersDislikeIncJob.perform_later(params[:id])
    end

  # end

end

run Rack::API