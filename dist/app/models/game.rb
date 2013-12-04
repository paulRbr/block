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
    if self.player1.nil? && !value.is_playing?
      value.played_first << self
      super value
    end
  end

  def player2=(value)
    if self.player2.nil? && !value.is_playing?
      value.played_second << self
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
end
