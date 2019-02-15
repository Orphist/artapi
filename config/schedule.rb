require File.expand_path(File.dirname(__FILE__) + '/environment')
set :output, {:standard => 'log/cron_log.log', :error => 'log/cron_error_log.log'}
env :PATH, ENV['PATH']

# job_type :runner, "cd ../#{File.dirname(__FILE__)} && rvm use 2.4.5@artapi && RAILS_ENV=development bundle exec rails runner ':task' :output"

every 1.minute do
  runner "ArticleCountersFlushJob.perform_later"
end