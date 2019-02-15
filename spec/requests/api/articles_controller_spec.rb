require 'rails_helper'

describe Api::V1::ArticlesController, :aggregate_failures, type: :request do

  before :context do
    FactoryBot.create_list(:article, 100, likes_counter: 0, dislikes_counter: 0)
  end

  describe "GET #index" do
    def get_index(headers = {})
      get '/api/articles/index.json', params: {}, headers: headers
    end

    it "returns ok 30 articles" do
      headers = { 'Range-Unit': 'items', 'Range': "0-29" }
      get_index(headers)
      expect(response).to have_http_status :partial_content #(206)
      expect(response_body["articles"]["data"]).not_to be_empty
    end
  end

  describe "PUT #like" do
    LIMIT_ARTICLES_COUNT = 42

    before do
      Article.update_all(likes_counter: 0)
      ArticleCounter.destroy_all
    end

    def put_like(id)
      put "/api/articles/#{id}/like.json", params: {}, headers: {}
    end

    it "returns 404" do
      put_like(999)
      expect(response).to have_http_status :not_found
    end

    it "returns ok 42*2 likes" do
      Article.limit(LIMIT_ARTICLES_COUNT).pluck(:id).each do |article_id|
        put_like(article_id)
        put_like(article_id)
      end
      ArticleCountersFlushJob.perform_now
      expect(Article.sum(:likes_counter)).to eq(LIMIT_ARTICLES_COUNT*2)
    end
  end

end
