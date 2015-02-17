class Card
	SUITS = [:Hearts, :Diamonds, :Clubs, :Spades]
	FACE_TO_VALUE = ((2...10).reduce({}) do |acc, value|
		acc[value] = [value]
		acc
	end).merge({
		:Jack => [10],
		:Queen => [10],
		:King => [10],
		:Ace => [1, 11]
	})

	attr_reader :suit, :face
	def initialize suit, face
		@suit = suit
		@face = face
	end

	def name
		@face.to_s + ' of ' + @suit.to_s
	end

	def values
		FACE_TO_VALUE[@face]
	end
end


class Hand < Array
	attr_reader :standing
	def initialize
		super()
		@standing = false
	end

	def values
		if self.empty?
			return [0]
		end

		result = []
		self[0].values.each do |value|
			self[1..-1].values.each do |subvalue|
				result << value + subvalue
			end
		end
		result.uniq!
		result
	end

	def best_value
		possibilities = values.select { |value| value <= 21 }
		possibilities.max || 0
	end

	def stand!
		@standing = true
	end

	def blackjack?
		values.include?(21)
	end
end


class Deck < Array
	def initialize
		Card::SUITS.each do |suit|
			Card::FACE_TO_VALUE.each do |face, value|
				self << Card.new(suit, face)
			end
		end
	end

	def draw(count=1)
		(0...count).collect { |value| self.shift }
	end
end