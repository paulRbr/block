class Game < ActiveRecord::Base
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player'
  belongs_to :winner, class_name: 'Player'

  attr_accessible :level, :token

  before_create :generate_token

  validates_uniqueness_of :token

  def winner=(value)
    if !finished? && (self.player1 == value || self.player2 == value)
      WebsocketRails[self.token.to_sym].trigger(:finished, value)
      super value
    end
  end

  def player1=(value)
    set_player 1, value do
      super value
    end
  end

  def player2=(value)
    set_player 2, value do
      super value
    end
  end

  def ready?
    !self.player1.nil? && !self.player2.nil?
  end

  def finished?
    !self.winner.nil?
  end

  def self.any_available
    available = self.includes(:player1).where(Player.arel_table[:id].eq(nil)).first
    available = self.includes(:player2).where(Player.arel_table[:id].eq(nil)).first_or_create if available.nil?
    available
  end

  private

  def generate_token
    self.token = SecureRandom.hex(12)
  end

  def set_player p, value
    if p == 2
      one = self.player2
      two = self.player1
      played = value.played_second
    elsif p == 1
      one = self.player1
      two = self.player2
      played = value.played_first
    else
      raise Exception("There are only two players in this game, you can't set_player #{p}")
    end

    if one.nil? && !value.is_playing?
      played << self
      yield
      WebsocketRails[self.token.to_sym].trigger(:ready, value) unless two.nil?
    end
  end
end
