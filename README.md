# README

perf optimal with puma 8 proc x 8 threads, CPU 4core/8threads

next steps to gain performance:
* move to Roda||Rack
* use Sequel instead AR
* take bigger server ;)

how to test w/JMeter:
* RAILS_ENV=production rails db:seed
* brew install jmeter --with-plugins
* rake jmx_article_likes_load
 

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
