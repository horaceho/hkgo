require 'optparse'
require 'roo'

options = {
    :default => {
        :ranks => 'na',
    },
    :output => {
        :record => false,
        :player => false,
    },
}

def import(filename, options)
    excel = Roo::Spreadsheet.open(filename, options)

    excel.default_sheet = excel.sheets[0] # Record
    rows = excel.parse(
        id: /Player_ID/,
        name: /Name/,
        elo: /Rating/,
        change: /Change/,
        date: /Update_Date/,
        match: /Competition/,
        won: /W/,
        lost: /L/,
        o1: /O1/,
        r1: /R1/,
        o2: /O2/,
        r2: /R2/,
        o3: /O3/,
        r3: /R3/,
        o4: /O4/,
        r4: /R4/,
        o5: /O5/,
        r5: /R5/,
        o6: /O6/,
        r6: /R6/,
        o7: /O7/,
        r7: /R7/,
        o8: /O8/,
        r8: /R8/,
        prize: /Prize/,
        clean: true
    )

    return rows
end

def convert(rows, options)
    records = {}
    players = {}
    count = 1
    rows.each do |row|
        count += 1

        player1 = row[:name]
        STDERR.puts "Row: #{count} Player name: #{player1}" if player1 =~ /\?/

        1.upto(8) do |i|
            round = "r#{i}"
            result = row[round.to_sym]
            next if result.nil?

            player2 = row["o#{i}".to_sym]
            next STDERR.puts "Row: #{count} Same player: #{player1} Date: #{row[:date]} Match: #{row[:match]} Opponent: O#{i} " if player1 == player2

            STDERR.puts "Row: #{count} Player name: #{player2}" if player2 =~ /\?/

            records[{
                :match => row[:match],
                :player1 => player1,
                :player2 => player2,
                :round => round,
            }] = {
                :date => row[:date],
                :winner => (result > 0) ? player1 : player2,
            }

            players[player1] = {
                :name => player1,
            }
            players[player2] = {
                :name => player2,
            }
        end
    end
    return records, players
end

def export(records, players, filename, options)
    if options[:output][:record]
        puts "Date,Player1,Player1 Rank,Player2,Player2 Ranks,Handicap,Difference," \
            "Winner Name,Winner Side,Result,Organization,Match,Round,Link,Remark"
        records.each do |key, value|
            puts "#{value[:date]},#{key[:player1]},,#{key[:player2]},,,0," \
                "#{value[:winner]},,,,#{key[:match]},#{key[:round].upcase},,"
        end
    end
    if options[:output][:player]
        puts "Player,Initial Rank"
        players.each do |player|
            puts "#{player[1][:name]},#{options[:default][:ranks]}"
        end
    end
end

parser = OptionParser.new do |syntax|
    syntax.banner = "Usage: ruby hogo.rb [options] {file}"
    syntax.on("", "--player", "Output players data") do
        options[:output][:player] = true
    end
    syntax.on("", "--record", "Output game records") do
        options[:output][:record] = true
    end
end
parser.parse!

if ARGV.size > 0
    if File.file?(ARGV[0])
        rows = import(ARGV[0], options)
        records, players = convert(rows, options)
        export(records, players, ARGV[1], options)
        STDERR.puts "records: #{records.count} players: #{players.count}"
    else
        puts "#{ARGV[0]} not found"
    end
else
    puts parser
end
