require 'optparse'
require 'roo'

options = {
    :default => {
        :ranks => '1d',
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
    rows.each do |row|
        players[row[:name]] = {
            :id => row[:id],
            :name => row[:name],
        }

        1.upto(8) do |i|
            number = "r#{i}"
            result = row[number.to_sym]
            next if result.nil?

            player1 = row[:name]
            player2 = row["o#{i}".to_sym]

            records[{
                :match => row[:match],
                :player1 => player1,
                :player2 => player2,
                :number => number,
            }] = {
                :date => row[:date],
                :winner => (result > 0) ? player1 : player2,
            }
        end
    end
    return records, players
end

def export(records, players, filename, options)
    if options[:output][:record]
        records.each do |key, value|
            # puts key, value
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
