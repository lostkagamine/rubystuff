# rubyboat comand handler v0.01
# (c) ry00001 2017

# <ryware>

require 'discordrb'

tk = open('token').read

bot = Discordrb::Bot.new token: tk, client_id: 348122769072062474

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!']
@suffix = [', do it', ' pls']

owner = 190544080164487168

@cmds = {}

def add_cmd(name, &block)
    @cmds[name] = block
end

add_cmd(:hi) do |e, args|
    e.respond "hi"
end

add_cmd(:eval) do |e, args|
    next unless e.author.id == owner
    begin
        o = eval args.join(' ')
        e.respond "Evaled successfully.\n\n```#{o}```"
    rescue => err
        e.respond "Error.\n\n```#{err}```"
    end
end

add_cmd(:ping) do |e, args|
    e.respond "hi"
end

add_cmd(:exit) do |e, args|
    next unless e.author.id == owner
    msgs = ['You\'re mean.', 'rip me I guess', 'Please don\'t shut me down...', 'Please no...', 'Shutting down...']
    e.respond msgs.sample
    exit!
end

def checktable(tbl, str) # util function
    tbl.each do |prfx|
        if str.start_with? prfx
            return true
        end
    end
    return false
end

def simtable(tbl, str) # util func #2
    tbl.each do |string|
        if str.start_with? string
            return string
        end
    end
    return false
end

def checktableend(tbl, str) # util func #3
    tbl.each do |prfx|
        if str.end_with? prfx
            return true
        end
    end
    return false
end

def simtableend(tbl, str) # util func #4
    tbl.each do |string|
        if str.end_with? string
            return string
        end
    end
    return false
end

class String
    def revsub(input, second = '')
        e = self.reverse.sub input.reverse, second # MOAR UTIL FUNCTIONS
        return e.reverse
    end
end

def do_cmd(cmd, event, args)
    begin
        a = @cmds[cmd.to_sym]
        return unless a
        a.call(event, args)
    rescue => a
        event.respond "ry is bad\n\n#{a}"
    end
end

## begin hecking command framework ##

bot.message do |event|
    if checktable(@prefix, event.content)
        # it's a command
        cmd = event.content[simtable(@prefix, event.content).length, event.content.length] # this will screw up 
        cmd = cmd.strip
        cmd = cmd.split(' ')[0]
        args = event.content.split(' ')
        args = args[1,args.length]
        do_cmd(cmd, event, args)
    end
    # i'm better off doing suffixes in another if block #
    if checktableend(@suffix, event.content)
        # yeah it's a command
        cmd = event.content.revsub(simtableend(@suffix, event.content))
        args = cmd.split(' ')
        args = args[1, args.length]
        cmd = cmd.strip
        cmd = cmd.split(' ')[0]
        do_cmd(cmd, event, args)
    end
end

## end hecking command framework ##

bot.run

# </ryware>