source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'json', '>=1.7.7'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'alphadecimal'
gem 'ejs'
gem 'pg'
gem 'cartodb-rb-client', :git => 'git://github.com/Vizzuality/cartodb-rb-client.git'
gem 'resque'
gem 'resque-status'
gem 'httmultiparty'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  #gem 'sass-rails',   '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem "paperclip", "~> 2.7"
gem "rubyzip"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
group :development, :test do
  #gem 'linecache19', '0.5.13', :path => "~/.rvm/gems/ruby-1.9.3-head/gems/linecache19-0.5.13/"
  #gem 'ruby-debug-base19', '0.11.26', :path => "~/.rvm/gems/ruby-1.9.3-head/gems/ruby-debug-base19-0.11.26/"

  gem 'ruby-debug19', :require => 'ruby-debug'

  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'brightbox'
end

group :test do
  gem 'minitest'
  gem 'turn'
end
