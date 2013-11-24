class Game < ActiveRecord::Base
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player'
  belongs_to :winner, class_name: 'Player'

  attr_accessible :level

  def winner=(value)
    super value if self.winner.nil? && (self.player1.eql?(value) || self.player2.eql?(value))
  end

  def player1=(value)
    super value if self.player1.nil?
  end

  def player2=(value)
    super value if self.player2.nil?
  end

  def finished?
    !self.winner.nil?
  end
end
