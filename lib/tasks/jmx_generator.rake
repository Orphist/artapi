$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', '**/*'))

desc 'Run JMeter - test article#(dis)likes - load testing'
task :jmx_article_likes_load, [:domain, :threads, :concurrency, :sleep] => :environment do |t, args|
  require 'ruby-jmeter'
  # brew install jmeter --with-plugins
  require_relative '../ruby_jmeter/dsl/view_results_in_hits_per_second_graph'
  require_relative '../ruby_jmeter/dsl/view_results_in_compose_graph'
  require_relative '../ruby_jmeter/dsl/view_results_in_2_graph'
  require_relative '../ruby_jmeter/dsl/view_results_in_3_graph'
  require_relative '../ruby_jmeter/dsl/view_results_in_4_graph'
  require_relative '../ruby_jmeter/dsl/view_results_in_5_graph'
  require_relative '../ruby_jmeter/dsl/view_results_in_6_graph'


  `rails log:clear`
  FileUtils.mkdir_p('tmp/performance')
  `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=#{Rails.env} rails database:prepare_testing_db`

  args.with_defaults(
                      domain: '127.0.0.1:3002',
                      threads: 64,
                      loads_entries: 100,
                      sleep: 1 )

  build = "pg_article_like_puma_8_8_th#{args[:threads]}_concur#{args[:loads_entries]}"
  load_multiplicator = 10
  time_multiplicator = 10

  warmup_duration = 60  # sec
  warmup_loops = 300
  total_test_duration = 200 # sec

  test do
    cookies policy: 'rfc2109', clear_each_iteration: true

    threads num_threads: args[:threads], # mean === concurrent users / threads = RPS * <max response time ms> / 1000
            count: args[:threads], # loads_entries
            rampup: warmup_duration,
            loops:  warmup_loops,
            duration: total_test_duration do

      throughput_shaper name: 'increasing load test', steps: [
          { :start_rps => 10*load_multiplicator, :end_rps => 10*load_multiplicator, :duration => 2*time_multiplicator },
          { :start_rps => 20*load_multiplicator, :end_rps => 20*load_multiplicator, :duration => 3*time_multiplicator },
          { :start_rps => 40*load_multiplicator, :end_rps => 40*load_multiplicator, :duration => 6*time_multiplicator },
          { :start_rps => 80*load_multiplicator, :end_rps => 80*load_multiplicator, :duration => 9*time_multiplicator }
      ]

      args[:loads_entries].times do |n|
        transaction name: "PUT#[dis]likes#{n}" do

          article_id = rand(Article.minimum(:id)..Article.maximum(:id))
          header([
                     { name: 'Content-Type', value: 'application/json' },
                     { name: 'Accept', value: 'application/api+json;version=1' }
                 ])
          endpoint_action = %w(like dislike).sample
          uri = "http://#{args[:domain]}/api/articles/#{article_id}/#{endpoint_action}.json"

          put url: uri, raw_body: { hey_teacher: 'leave the kids alone!' }.to_json

        end
        transaction name: "GET#index#{n}" do

          article_from_id = rand(Article.minimum(:id)-1..Article.maximum(:id)-1)
          article_till_id = article_from_id + 100

          header([
                     { name: 'Content-Type', value: 'application/json' },
                     { name: 'Accept', value: 'application/api+json;version=1' },
                     { name: 'Range-Unit', value: 'items' },
                     { name: 'Range', value: "#{article_from_id}-#{article_till_id}" }
                 ])

          uri = "http://#{args[:domain]}/api/articles/index.json"

          get url: uri
        end
      end


      view_results_in_table
      view_results_tree
      graph_results
      aggregate_graph

      response_time_graph

      ## custom charts/presenters from plug-ins
      # view_results_in_compose_graph # broken
      view_results_in_hits_per_second_graph
      view_results_in_transaction_per_sec_graph
      # view_results_in_3_graph # bghha
      view_results_in_4_graph
      # view_results_in_5_graph # empty data
      view_results_in_6_graph
    end


  end.run(
      path: '/usr/local/bin',
      gui: true,
      file: Rails.root.join('tmp','performance',"jmeter_#{build}.jmx"),
      log: Rails.root.join('log','jmeter.log'),
      jtl: Rails.root.join('tmp','performance',"results_#{build}.jtl"),
      # properties: 'jmeter.properties'
  )

end

