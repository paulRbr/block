require 'bundler/setup'
require 'sprockets-vendor_gems/extend_all'
require 'uglifier'
Bundler.require

assets = Sprockets::Environment.new('.') do |env|
  env.logger = Logger.new(STDOUT)
end

assets.register_engine '.haml', Tilt::HamlTemplate

assets.append_path('.')
assets.append_path('app')
assets.append_path('app/layouts')

get '/*' do
  new_env = env.clone
  assets.call(new_env)
end

