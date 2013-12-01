class Player < ActiveRecord::Base
  has_many :played_first, :class_name => 'Game', foreign_key: 'player1_id'
  has_many :played_second, :class_name => 'Game', foreign_key: 'player2_id'

  attr_accessible :level, :name

  validates_uniqueness_of :token

  def played
    played_first + played_second
  end

  def playing
    played.select{ |game| game.winner.nil? }
  end

  def is_playing?
    !playing.empty?
  end

end
