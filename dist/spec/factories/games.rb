require 'factory_girl'

FactoryGirl.define do
  factory :game do
    level 1
    factory :ongoing_game do
      association :player1, factory: :player
      association :player2, factory: :player
    end
    factory :finished_game do
      association :player1, factory: :player
      association :player2, factory: :player
    end
  end
end