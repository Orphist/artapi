class ArticleSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :underscore

  attributes :title, :description, :likes_counter, :dislikes_counter
end