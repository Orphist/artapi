source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'

# Use Puma as the app server
gem 'puma', '~> 3.11'
# gem 'falcon', github: 'socketry/falcon' # puma replacement, nio4r needed

# API pagination the way RFC7233,
# also Semantic HTTP - built in strict conformance to RFCs 2616 and 5988
gem 'clean_pagination', github: 'begriffs/clean_pagination'

gem 'responders'
gem 'fast_jsonapi', github: 'Netflix/fast_jsonapi'
gem 'api-versions', '~> 1.0'

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-remote'

  gem 'rspec-rails', '~> 3.5'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'ffaker'
  gem 'database_cleaner'
end
