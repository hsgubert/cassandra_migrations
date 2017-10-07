%w(3.2 4.0 4.2 5.1).each do |rails_version|
  appraise "rails-#{rails_version}" do
    gem "rails", "~> #{rails_version}.0"
  end
end

appraise "rails-5.0.0.rc1" do
  gem "rails", "~> 5.0.0.rc1"
end
