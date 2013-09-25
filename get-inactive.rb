require 'date'

# Guild Wars 2 guild members activity detector
# Usage:
#  - Go to the Guild Wars 2 website, and log to your account.
#  - Get to the Leaderboard page, choose the Achievements leaderboard.
#  - Filter by guild, selecting the guild you want to get data on.
#  - Save the page in the 'data' folder of this project, as 'data.htm'.
#  - Run the script and profit.

# Stores information about a player in the guild.
class Player
	attr_reader :name, :points, :lastConnection

	def initialize(name, points, lastConnection)
		@name = name
		@points = points
		@lastConnection = lastConnection
	end

	def to_s
		return @name + " (" + @points + ", " + @lastConnection.to_s + ")"
	end
end

# Function to parse the data file provided.
def getPlayers(file)
	playerBlockRegex = /.*>(?<name>[A-Za-z ]+.[0-9]{4})<.*>(?<points>\d+)<.*>\d*Since(?<date>[^<]+)<.*>([^<]+)<.*/
	inPlayerBlock = false
	playerBlock = ""
	playersList = []

	File.open( file ).each do |line|
		# Trim the line and pass it if it's empty.
		line.strip!
		next if line.length == 0

		# Concentrate on the core of the table.
		next unless line[/^<table class="lb real achievements"/] .. line[/^<\/table>/]
		next unless line[/^<tbody/] .. line[/<\/tbody>/]

		# Look for a player block.
		if line[/^<tr/] then
			playerBlock = ""
			inPlayerBlock = true
		end

		if inPlayerBlock then
			if line[/^<\/tr/] then
				data = playerBlockRegex.match(playerBlock)
				if data == nil then
					puts "The RegEx doesn't capture this: " + playerBlock
				else
					lastConnection = DateTime.strptime(data[:date], '%m/%d/%y %I:%M %p %Z')
					playersList.push(Player.new(data[:name], data[:points], lastConnection))
				end
			else
				playerBlock += line
			end
		end
	end

	return playersList
end

# Parse the data file, and display players with the less active first.
players = getPlayers("data/data.htm")
players.sort_by! { |p| p.lastConnection }
puts players