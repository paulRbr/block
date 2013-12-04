require 'factory_girl'

FactoryGirl.define do
  factory :player, aliases: [:player1, :player2] do
    after(:build) { |player| player.token = SecureRandom.hex(4) }
  end
end