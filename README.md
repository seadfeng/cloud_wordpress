# Wordpress
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "wordpress", git: "git@gitlabonline.seadapp.com:wordpress/cloud.git"
gem "active_admin_role", github: "seadfeng/active_admin_role"
```

And then execute:
```bash
$ bundle install 
$ rails webpacker:install
$ rails g active_admin:install
$ rails g wordpress:install
$ rake db:migrate
$ rake db:seed
```

## System dependence
rails 6.0+
mysql 8.0+


## Sidekiq Service

https://github.com/mperham/sidekiq/blob/07c0e1f4e60298deeab70999f6a33c86959f196a/examples/systemd/sidekiq.service

## Webpacker Using in Rails engines

https://github.com/rails/webpacker/blob/master/docs/engines.md

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
