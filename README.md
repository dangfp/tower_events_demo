# README
  2
  3 ## Install
  4
  5 * Ruby version
  6     1. `ruby-2.3.1`
  7
  8 * Configuration(copy and edit sample file)
  9     1. `config/database.yml`
 10     2. `config/application.yml`
 11
 12 * Database creation
 13     1. `bundle exec rake db:drop`  (删除数据库, 如果已有数据库)
 14     1. `bundle exec rake db:setup` (创建数据库, 初始化 Seed 数据)
 15     1. 或者使用 `bundle exec rake db:reset`, 包含了上面的 `drop` 和 `setup`
 16
 17 * How to run the test suite
 18     1. `bundle exec rake test test/`
 
