source "https://rubygems.org"

if ENV["RAILS_VERSION"] == "edge"
  gem "rails", git: "https://github.com/rails/rails.git", branch: "main"
end

# Lock loofah to old version for Ruby 2.4
unless RUBY_VERSION > "2.5"
  gem "loofah", "~> 2.20.0"
end

gemspec
