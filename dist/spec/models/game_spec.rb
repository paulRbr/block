require 'spec_helper'

describe Game do

  it "doesn't change an ongoing game's players" do
    game = FactoryGirl.create :ongoing_game
    new_player = FactoryGirl.create :player
    game.player1 = new_player
    game.player2 = new_player
    game.save

    game.player1.should_not eq new_player
    game.player2.should_not eq new_player
    should_not be game.finished?
  end

  it "doesn't change the existing winner" do
    game = FactoryGirl.create :ongoing_game
    game.winner = game.player1
    game.save

    game.winner.should eq game.player1

    game.winner = game.player2
    game.save

    game.winner.should_not eq game.player2
  end

  context "when a player leaves an ongoing game" do
    before(:each) do
      @game = FactoryGirl.create :ongoing_game
      player = @game.player1
      player.destroy
    end

    it "sets the winner" do
      @game.winner.should be @game.player2
    end

    it "triggers a finished event on the game channel" do
       # TODO
    end
  end
end
