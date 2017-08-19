require 'discordrb'

tk = open('token').read

bot = Discordrb::Bot.new token: tk, client_id: 348122769072062474

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!']

owner = 190544080164487168

@cmds = {}

def add_cmd(name, &block)
    @cmds[name] = block
end

add_cmd(:hi) do |e, args|
    e.respond "hi"
end

add_cmd(:eval) do |e, args|
    break unless e.author.id == owner
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

## begin hecking command framework ##

bot.message do |event|
    if checktable(@prefix, event.content)
        # it's a command
        cmd = event.content[simtable(@prefix, event.content).length, event.content.length] # this will screw up 
        cmd = cmd.strip
        cmd = cmd.split(' ')[0]
        args = event.content.split(' ')
        args = args[1,args.length]
        p args
        p cmd
        begin
            @cmds[cmd.to_sym].call(event, args)
        rescue => a
            event.respond "ry is bad\n\n#{a}"
        end
    end
end

## end hecking command framework ##

bot.run