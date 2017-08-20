# rubyboat comand handler v -insert version number from config.yml here-
# (c) ry00001 2017

# <ryware>

require 'discordrb'
require 'yaml'
require 'base64'

config = YAML.load_file 'config.yml' # ok]
tk = config['login']['token']
id = config['login']['id']
owner = config['settings']['owner']
version = config['settings']['version']

bot = Discordrb::Bot.new token: tk, client_id: id

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!', 'hey ruboat, can you do ', 'pls ']
@suffix = [', do it', ' pls']

@cmds = {}
@descs = {}
@subcmds = {}

def add_cmd(name, desc, &block)
    @cmds[name] = block
    @descs[name] = desc
end

def add_subcmd(cmd, sname, &block)
    if !@subcmds.key? cmd
        @subcmds[cmd] = {}
    end
    @subcmds[cmd][sname] = block
end

def do_help_sub(cmd, event)
    cmd = cmd.to_sym
    event.channel.send_embed("") do |embed|
        begin
            embed.color = 0x00FF00
            embed.title = "Command info for #{cmd}"
            embed.add_field(name: 'Description', value: @descs[cmd])
            next unless @subcmds[cmd]
            a = @subcmds[cmd].keys().join(', ')
            embed.add_field(name: 'Subcommands', value: "```\n#{a}```")
        rescue => a
            embed.color = 0xFF0000
            embed.title = 'Oops.'
            embed.description = 'Whoops! This isn\'t meant to happen! Ever! Please do Ry a favour and tell him.'
            embed.add_field(name: 'Error details', value: "```\n#{a}```")
        end
    end
end



add_cmd(:hi, "Hello.") do |e, args|
    e.respond "hi"
end

add_cmd(:eval, 'Please don\'t try to use this. Seriously, don\'t.') do |e, args|
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
    if !args[0]
        lul = @cmds.keys
        mmLol = @descs.values
        e.channel.send_embed("") do |embed|
            embed.colour = 0x00FF00
            embed.title = "RubyBoat Commands"
            lul.each_with_index do |key, ind|
                if @subcmds[key.to_sym] # check if it has any subcommands. if it does, doc them.
                    scmds = "\n\n**Available subcommands:**\n`#{@subcmds[key.to_sym].keys.join(', ')}`"
                    embed.add_field(name: key, value: mmLol[ind] + scmds, inline: false)
                else
                    embed.add_field(name: key, value: mmLol[ind], inline: false)
                end
            end
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Do \'help <command>\' for not-that-much-more info.')
        end
    else
        do_help_sub(args[0], e)
    end
end

add_cmd(:invoke, 'Manage Ruboat\'s invokers.') do |e, args|
    if args[0] != nil
        do_subcmd(:invoke, args[0].to_sym, e, args)
    end
end

add_subcmd(:invoke, :list) do |e, args|
    e.respond "**RubyBoat Invokers**\n\n```\nPrefixes: #{@prefix.join(' | ')}\nSuffixes: #{@suffix.join(' | ')}```"
end

add_subcmd(:invoke, :add_prefix) do |e, args|
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
end

add_subcmd(:invoke, :add_suffix) do |e, args|
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
end

add_cmd(:base64, 'Do stuff with Base64!') do |e, args|
    if args[0] != nil
        do_subcmd(:invoke, args[0].to_sym, e, args)
    end
end

add_subcmd(:base64, :encode) do |e, args|
    text = args.join(' ')
    b64 = Base64.encode64(text).chomp
    e.respond "**Base64 Encode**\n\nYour encoded text is `#{b64}`"
end

add_subcmd(:base64, :decode) do |e, args|
    text = args.join(' ')
    b64 = Base64.decode64(text).chomp
    e.respond "**Base64 Encode**\n\nYour encoded text is `#{b64}`"
end

add_cmd(:error, 'ok') do |e, args|
    next unless e.author.id == owner
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

def do_subcmd(cmd, subcmd, event, args)
    begin
        a = @subcmds[cmd.to_sym][subcmd.to_sym]
        if !a
            return event.respond "Um, that\'s not a subcommand. Available subcommands are `#{@subcmds[cmd.to_sym].keys.join(', ')}`."
        end
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

bot.ready do
    puts 'bot ready'
    bot.game = "rb!help / rb!invoke list | rubyboat v#{version}"
end

## end hecking command framework ##

bot.run

# </ryware>