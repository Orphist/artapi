namespace :database do
  desc "Prepare database"
  task :prepare_testing_db => [:environment] do

    ["database:pg_terminate", "db:drop", "db:create", "db:migrate", "db:seed"].each do |cmd|
      begin
        puts "#{Time.now} call #{cmd} step"
        Rake::Task[cmd].invoke
      rescue PG::Error => err
        puts err
        binding.pry
      end
    end

  end

  desc "Terminate Postgres sessions to enable db:drop"
  task pg_terminate: :environment do
    ActiveRecord::Base.connection.begin_db_transaction
    retcode = `echo 'SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = current_database() AND pg_stat_activity.pid <> pg_backend_pid();' | rails db`.to_i
    abort "Failed to drop all connections in #{Rails.configuration.database_configuration[Rails.env]["database"]} with retcode='#{retcode}'" unless retcode == 0
  end

end
