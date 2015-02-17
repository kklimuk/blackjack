require_relative "player"
require_relative "cards"

class BlackJack
	attr_reader :deck, :dealer

	def initialize players
		@deck = Deck.new
		@dealer = Dealer.new
		@players = players
	end

	def start_game
		while true
			@deck = Deck.new.shuffle!
			(@players + [@dealer]).each do |player|
				player.reset
				player.hands.first.push *@deck.draw(2)
			end

			@players.each_with_index { |player, index| 
				puts "Player #{ index + 1 }, it is your turn:\n\n"
				player.play self 
				puts ""
			}

			@dealer.play self

			@players.each_with_index { |player, index| 
				puts "Player \##{ index + 1 } results:"
				player.resolve_game @dealer.hands.first
				puts ""
			}
		end
	end

	def hit!(hand)
		hand.push *@deck.draw
		self
	end

	def split!(player)
		player.hands << Hand.new.push(player.hands.first.shift)
		player.hands.each do |hand|
			hand.push *@deck.draw
		end

		self
	end
end

puts "How many players?"
value = 0
while (value = gets.to_i) == 0
end

game = BlackJack.new((0...value).collect { |value| Player.new }).start_game
