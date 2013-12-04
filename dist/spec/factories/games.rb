require 'factory_girl'

FactoryGirl.define do
  factory :game do
    level 1
    factory :ongoing_game do
      player1
      player2
    end
  end
end