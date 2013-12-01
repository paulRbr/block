class Game < ActiveRecord::Base
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player'
  belongs_to :winner, class_name: 'Player'

  attr_accessible :level

  before_create :generate_token

  validates_uniqueness_of :token

  def winner=(value)
    super value if !finished? && (self.player1.eql?(value) || self.player2.eql?(value))
  end

  def player1=(value)
    if self.player1.nil?
      value.played_first << self
      super value
    end
  end

  def player2=(value)
    if self.player2.nil?
      value.played_second << self
      super value
    end
  end

  def finished?
    !self.winner.nil?
  end

  def self.any_available
    available = self.includes(:player1).where(Player.arel_table[:id].eq(nil)).first
    available = self.includes(:player2).where(Player.arel_table[:id].eq(nil)).first if available.nil?
    available
  end

  private

  def generate_token
    self.token = SecureRandom.hex(12)
  end
end
