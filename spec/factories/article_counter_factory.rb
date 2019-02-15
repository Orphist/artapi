FactoryBot.define do

  factory :article_counter do
    article_id { create(:article).id }
    like { rand(0..42) }
    dislike { rand(0..42) }
  end

end
