# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'factory_bot_rails'
require 'factory_bot'

## init
limit = 100
user_limit = 100
ip_limit = 50

FactoryBot.create_list(:user, user_limit) if User.all.size.zero?
posts = FactoryBot.build_list(:post, limit)

titles      = posts.pluck(:title)
contents    = posts.pluck(:content)
mean_scores = posts.pluck(:mean_score)
ip_addrs    = posts.pluck(:ip_addr)[0..ip_limit]
user_ids    = User.all.pluck(:id)

columns = [:title, :content, :mean_score, :user_id, :ip_addr]

## bulk insert Post
10.times do |iter|
  values = (1..limit).map do |id|
    mean_score = (limit*0.5)<id ? nil : mean_scores[id]
    [titles[rand*(id)], contents[rand*(id)], mean_score, user_ids[rand*(user_limit)], ip_addrs[rand*(20)]]
  end
  Post.import(columns, values, validate: false)
  puts "#{Time.now} #{iter*limit} records inserted" if iter%20 == 0
end