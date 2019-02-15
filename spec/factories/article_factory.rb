FactoryBot.define do

  factory :article do
    title { FFaker::Name.name }
    description { FFaker::Lorem.sentence(rand(10..20)) }
    likes_counter { rand(10..20) }
    dislikes_counter { rand(10..20) }
  end

end
