class Player < ActiveRecord::Base
  has_many :played_first, :class_name => 'Game', foreign_key: 'player1_id'
  has_many :played_second, :class_name => 'Game', foreign_key: 'player2_id'

  attr_accessible :level, :name

  validates_uniqueness_of :token

  before_destroy :loose_playing_game

  def played
    self.played_first + played_second
  end

  def playing
    self.played.select{ |game| game.winner.nil? }
  end

  def is_playing?
    !self.playing.empty?
  end

  private

  def loose_playing_game
    if self.is_playing?
      winner = self.playing.first.player1.id == self.id ? self.playing.first.player2 : self.playing.first.player1
      playing.first.winner = winner
    end
    true
  end
end
