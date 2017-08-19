# rubyboat comand handler v0.01
# (c) ry00001 2017

# <ryware>

require 'discordrb'

tk = open('token').read

bot = Discordrb::Bot.new token: tk, client_id: 348122769072062474

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!', 'hey ruboat, can you do ']
@suffix = [', do it', ' pls']
@regex = [/$ do it/] # experimental(tm) regex(tm) feature(tm)

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
    msgs = ['Is this the part where I say pong?', 'gnoP!', 'Pong, I guess.', 'Pong...?', 'Do you want a pong? This isn\'t how to get a pong.']
    e.respond msgs.sample
end

add_cmd(:exit) do |e, args|
    next unless e.author.id == owner
    msgs = ['You\'re mean.', 'rip me I guess', 'Please don\'t shut me down...', 'Please no...', 'Shutting down...']
    e.respond msgs.sample
    exit!
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
        event.respond "ry is bad\n\n#{a}"
    end
end

def check_prefix(content, prefixes)
    prefixes.each { |prefix|
        m = content.match(/^#{Regexp.escape(prefix)}\s*(\S*)\s*(.*)/m)
        next unless m
        raw, command, args = m[0], m[1], m[2]
        return raw, command, args
    }
end

def check_suffix(content, prefixes)
    prefixes.each { |prefix|
        m = content.match(/(\S*)\s*(.*)#{Regexp.escape(prefix)}$/m)
        next unless m
        raw, command, args = m[0], m[1], m[2]
        return raw, command, args
    }
end

## begin hecking command framework ##

bot.message do |event|
    raw, cmd, args = check_prefix(event.content, @prefix)
    if cmd 
        do_cmd(cmd, event, args) 
    end
    raw, cmd, args = check_suffix(event.content, @suffix)
    if cmd
        do_cmd cmd, event, args
    end
end

## end hecking command framework ##

bot.run

# </ryware>