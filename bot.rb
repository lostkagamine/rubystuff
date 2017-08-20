# rubyboat comand handler v0.01
# (c) ry00001 2017

# <ryware>

require 'discordrb'
require 'yaml'

config = YAML.load_file 'config.yml' # ok]
tk = config['login']['token']
id = config['login']['id']
owner = config['settings']['owner']

bot = Discordrb::Bot.new token: tk, client_id: id

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!', 'hey ruboat, can you do ', 'pls ']
@suffix = [', do it', ' pls']
@regex = [/$ do it/] # experimental(tm) regex(tm) feature(tm)

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
    mmLol = e.respond msgs.sample
    mmLol.edit mmLol.content + " | #{Integer((mmLol.timestamp - e.timestamp)*1000)}ms"
end

add_cmd(:exit, 'Nooooo!') do |e, args|
    next unless e.author.id == owner
    msgs = [
        'You\'re mean. :(',
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

add_cmd(:invoke, 'Manage Ruboat\'s invokers.') do |e, args|
    if args[0] == 'list'
        e.respond "**RubyBoat Invokers**\n\n```\nPrefixes: #{@prefix.join(' | ')}\nSuffixes: #{@suffix.join(' | ')}```"
    elsif args[0] == 'add_prefix'
        prefix = args[1, args.length]
        prefix = prefix.join ' '
        prefix = prefix.tr '"', ''
        prefix = prefix.tr "'", ''
        if !@prefix.include? prefix
            @prefix << prefix
            e.respond ':ok_hand:'
        else
            e.respond 'Um, nope. No duplicates allowed.'
        end
    elsif args[0] == 'add_suffix'
        suffix = args[1, args.length]
        suffix = suffix.join ' '
        suffix = suffix.tr '"', ''
        suffix = suffix.tr "'", ''
        if !@suffix.include? suffix
            @suffix << suffix
            e.respond ':ok_hand:'
        else
            e.respond 'Um, nope. I\'m afraid I can\'t let you do that. This suffix is already present.'
        end
    elsif args[1] == 'del_prefix'
        prefix = args[1, args.length]
        prefix = prefix.join ' '
        prefix = prefix.tr '"', ''
        prefix = prefix.tr "'", ''
        if @prefix.include? prefix
            @prefix.delete prefix
            e.respond ':ok_hand:'
        else
            e.respond 'This isn\'t even a prefix, you meme.'
        end
    elsif args[1] == 'del_suffix'
        suffix = args[1, args.length]
        suffix = suffix.join ' '
        suffix = suffix.tr '"', ''
        suffix = suffix.tr "'", ''
        if @suffix.include? prefix
            @suffix.delete(prefix)
            e.respond ':ok_hand:'
        else
            e.respond 'Nope, not a suffix. Please use a valid suffix instead.'
        end
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