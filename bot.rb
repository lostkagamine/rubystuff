# rubyboat comand handler v0.01
# (c) ry00001 2017

# <ryware>

require 'discordrb'

tk = open('token').read

bot = Discordrb::Bot.new token: tk, client_id: 348122769072062474

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!', 'hey ruboat, can you do ', 'pls ']
@suffix = [', do it', ' pls']
@regex = [/$ do it/] # experimental(tm) regex(tm) feature(tm)

owner = 190544080164487168

@cmds = {}

@descs = {}

def add_cmd(name, desc, &block)
    @cmds[name] = block
    @descs[name] = desc
end

add_cmd(:hi, "Hello.") do |e, args|
    e.respond "hi"
end

add_cmd(:eval, 'Please don\'t try to use this.') do |e, args|
    next unless e.author.id == owner
    begin
        o = eval args.join(' ')
        e.respond "Evaled successfully.\n\n```#{o}```"
    rescue => err
        e.respond "Error.\n\n```#{err}```"
    end
end

add_cmd(:ping, 'Pong?') do |e, args|
    msgs = [
        'Is this the part where I say pong?',
        'gnoP!',
        'Pong, I guess.',
        'Pong...?',
        'Do you want a pong? This isn\'t how to get a pong.'
    ]
    e.respond msgs.sample
end

add_cmd(:exit, 'Nooooo!') do |e, args|
    next unless e.author.id == owner
    msgs = [
        'You\'re mean.',
        'rip me I guess',
        'Please don\'t shut me down...',
        'Please no...',
        'Shutting down...',
        'Thanks anyway...',
        'I don\'t hate you.'
    ]
    e.respond msgs.sample
    exit!
end

add_cmd(:help, '...') do |e, args|
    lul = @cmds.keys
    mmLol = @descs.values
    e.channel.send_embed("") do |embed|
        embed.colour = 0x00FF00
        embed.title = "RubyBoat Commands"
        lul.each_with_index do |key, index|
            lul[index] = "**#{key}** - #{mmLol[index]}"
        end
        embed.description = lul.join("\n")
    end
end

add_cmd(:error, 'ok') do |e, args|
    break unless e.author.id == owner
    e.respond "This is intended. Please don't tell Ry about it."
    e.respond 3/0
end

def checktblmatch(tbl, str)
    tbl.each do |regex|
        if str.match(regex)
            return true
        end
    end
    return false
end

def tblgsub(tbl, str)
    tbl.each do |regex|
        if str.match(regex)
            return str.gsub(regex)
        end
    end
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
        event.channel.send_embed("") do |embed|
            embed.title = "An error occurred."
            embed.description = "In essence, Ry is bad. Just... go ahead and tell him or something."
            embed.colour = 0xFF0000
            embed.add_field(name: "Error info", value: "```\n#{a}```")
        end
    end
end

def check_prefix(content, prefixes)
    prefixes.each { |prefix|
        m = content.match(/^#{Regexp.escape(prefix)}\s*(\S*)\s*(.*)/m)
        next unless m
        raw, command, args = m[0], m[1], m[2]
        args = args.split(' ')
        return raw, command, args
    }
end

def check_suffix(content, prefixes)
    prefixes.each { |prefix|
        m = content.match(/(\S*)\s*(.*)#{Regexp.escape(prefix)}$/m)
        next unless m
        raw, command, args = m[0], m[1], m[2]
        args = args.split(' ')
        return raw, command, args
    }
end

## begin hecking command framework ##

bot.message do |event|
    raw, cmd, args = check_prefix event.content, @prefix
    if cmd 
        do_cmd cmd, event, args
    end
    raw, cmd, args = check_suffix event.content, @suffix
    if cmd
        do_cmd cmd, event, args
    end
end

## end hecking command framework ##

bot.run

# </ryware>