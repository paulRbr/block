require 'spec_helper'

describe Player do

  context "when playing" do
    before do
      @game = FactoryGirl.create :ongoing_game
      @player = @game.player1
    end
    it "has a reference to the playing game" do
      @player.playing.should include @game
    end
    context "when it is destroyed" do
      it "looses the playing game" do
        @player.destroy
        @game.winner.should_not be nil
        @game.winner.should_not be @player
      end

    end
  end

  context "when already played" do
    it "has a list of played games" do
      game = FactoryGirl.create :ongoing_game
      game.player1.played.should include game
    end
  end

  context "when never played" do
    it "is not playing" do
      player = FactoryGirl.create :player
      should_not be player.is_playing?
    end
  end

end
