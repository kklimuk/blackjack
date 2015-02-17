require_relative 'money'

class CommonPlayer
	attr_reader :hands
	def initialize
		@hands = []
	end

	def reset
		@hands = [ Hand.new ]
	end

	def show_hand(hand)
		hand.collect { |card| card.name }
	end
end


class Player < CommonPlayer
	attr_reader :money

	ACTION_TO_NAME = {
		:dd => "Double Down (dd)",
		:sp => "Split (sp)",
		:h => "Hit (h)",
		:s => "Stand (s)"
	}

	def initialize(money=1000)
		super()
		@money = money
	end

	def actions(bet, hand)
		[
			if double_down?(bet) then :dd else nil end,
			if split?() then :sp else nil end,
			if hit?(hand) then :h else nil end,
			if stand?(hand) then :s else nil end
		].select do |action|
			not action.nil?
		end
	end

	def get_action(available_actions)
		action_representations = available_actions.collect do |action|
			ACTION_TO_NAME[action]
		end

		puts "Type the action name in parentheses to perform it: #{ action_representations.join(', ') }"

		action = gets.chomp.to_sym
		if not available_actions.include?(action)
			get_action available_actions
		end
		puts ""

		action
	end

	def play(game)
		begin
			@bet = Bet.new @money
			puts "The dealer's hand is a #{ game.dealer.show_hand.join " and " }.\n\n"
			
			while @hands.any? { |hand| stand?(hand) }
				@hands.each_with_index do |hand, index|
					while stand?(hand)
						current_actions = actions(@bet, hand)
						cards = show_hand(hand)

						message = "Your \##{ index + 1 } hand is #{ cards.join ", " }.\n"
						message << if hand.blackjack?
							"You have blackjack!"
						else 
							"It is valued at #{ @hands[index].values.join " or " }.\n\n" 
						end
						puts message

						action = get_action(current_actions)
						case action
						when :dd
							@bet.double_down!
						when :sp
							game.split!(self)
						when :h
							game.hit!(hand)
						when :s
							hand.stand!
						end
					end					
				end
			end

			self
		rescue ArgumentError # happens if there's no more money to bet
			return self
		end
	end

	def resolve_game(against)
		current_money = @money
		@hands.each do |hand|
			puts against.best_value, hand.best_value
			if hand.blackjack? && !against.blackjack?
				@money += @bet.amount * 1.5
			elsif hand.best_value > against.best_value
				@money += @bet.amount
			elsif hand.best_value < against.best_value
				@money -= @bet.amount
			end
		end
		difference = @money - current_money
		if difference > 0
			puts "You won $#{difference}"
		elsif difference < 0
			puts "You lost $#{difference.abs}"
		elsif difference
			puts "Push!"
		end
	end

	def double_down?(bet)
		bet.amount * 2 <= @money
	end

	def hit?(hand)
		hand.values.min < 21 && !hand.blackjack?
	end

	def stand?(hand)
		!hand.standing
	end

	def split?
		@hands.length == 1 and @hands.all? do |hand|
			hand.length == 2 and hand.first.values == hand.last.values	
		end
	end
end


class Dealer < CommonPlayer
	def initialize
		super()
	end

	def hit?(hand)
		hand.best_value < 17 && hand.best_value != 0
	end

	def play(game)
		while hit? @hands.first
			game.hit! @hands.first
		end

		cards = self.class.superclass.instance_method(:show_hand).bind(self).call(@hands.first)
		puts "The dealer's hand is a #{ cards.join ", " }.\n\n"

		self
	end

	def show_hand
		# interesting how it's hard to call a superclass method in ruby
		cards = self.class.superclass.instance_method(:show_hand).bind(self).call(@hands.first)
		cards.shift
		cards.unshift "Face Down Card"
		cards
	end
end
