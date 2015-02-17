class Bet
	MIN_AMOUNT = 10

	attr_reader :amount
	def initialize(player_money)
		raise ArgumentError, 'Not enough money to play' if player_money < MIN_AMOUNT

		puts "You currently have $#{ player_money } and the minimum bet is $#{MIN_AMOUNT}.\nPlease place a bet:"
		@amount = gets.chomp.to_i
		while @amount < MIN_AMOUNT or @amount > player_money
			puts "Please place more than the minimum amount" if @amount < MIN_AMOUNT
			puts "Please place less than the total amount you have ($#{ player_money })"
			@amount = gets.chomp.to_i
		end
		puts ""
	end

	def double_down!
		@amount *= 2
	end
end