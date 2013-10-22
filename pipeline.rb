require 'bundler/setup'
require 'sprockets-vendor_gems/extend_all'
require 'uglifier'
Bundler.require

assets = Sprockets::Environment.new('.') do |env|
  env.logger = Logger.new(STDOUT)
end

assets.register_engine '.haml', Tilt::HamlTemplate

assets.append_path('js')
assets.append_path('html')
assets.append_path('vendor/assets/javascripts')

get '/*' do
  new_env = env.clone
  assets.call(new_env)
end

