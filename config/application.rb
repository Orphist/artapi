require_relative 'boot'

# require 'rails/all'

require "active_record/railtie"
# require "active_storage/railtie"
require "action_controller/railtie"
# require "action_view/railtie"
# require "action_mailer/railtie"
require "active_job/railtie"
# require "action_cable/railtie"
# require "rails/test_unit/engine"
# require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Artapi
  class Application < Rails::Application
    %w(services jobs serializers subscribers).each do |path|
      config.autoload_paths   += Dir[Rails.root.join('app',path,'**/')]
      config.eager_load_paths += Dir[Rails.root.join('app',path,'**/')]
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.active_job.queue_adapter = :sucker_punch
  end
end
