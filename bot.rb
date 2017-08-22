# rubyboat comand handler v -insert version number from config.yml here-
# (c) ry00001 2017

# <ryware>

require 'discordrb'
require 'yaml'
require 'base64'
require_relative 'utils/utils'

config = YAML.load_file 'config.yml' # ok]
tk = config['login']['token']
id = config['login']['id']
owner = config['settings']['owner']
version = config['settings']['version']

class Bot < Discordrb::Bot
    def initialize(*args)
        super *args
        @cmds = {}
        @descs = {}
        @subcmds = {}
    end

    def add_cmd(name, desc, &block)
        @cmds[name] = Command.new name, desc, block
    end

    def add_subcmd(cmd, sname, &block)
        if !@subcmds.key? cmd
            @subcmds[cmd] = {}
        end
        @subcmds[cmd][sname] = Command.new sname, "[SUBCOMMAND OF #{cmd}]", block
    end

    def do_cmd(cmd, event, args)
        begin
            a = @cmds[cmd.to_sym]
            return unless a
            a.call(event, args)
        rescue => a
            UtilMethods.do_error_embed(a, event)
        end
    end

    def do_subcmd(cmd, subcmd, event, args)
        begin
            a = @subcmds[cmd.to_sym][subcmd.to_sym]
            if !a
                return event.respond "Um, that\'s not a subcommand. Available subcommands are `#{@subcmds[cmd.to_sym].keys.join(', ')}`."
            end
            a.call event, args.drop(1)
        rescue => a
            UtilMethods.do_error_embed(a, event)
        end
    end
end

class Command
    def initialize(name, desc, block)
        @name = name
        @description = desc
        @caller = block
    end

    def call(event, *args)
        @caller.call(event, *args)
    end
end

bot = Bot.new token: tk, client_id: id

puts "Bot invite link: #{bot.invite_url}"

@prefix = ['rb!', 'r!', 'hey ruboat, can you do ', 'pls ']
@suffix = [', do it', ' pls']



bot.add_cmd(:hi, "Hello.") do |e, args|
    e.respond "hi"
end

bot.add_cmd(:eval, 'Please don\'t try to use this. Seriously, don\'t.') do |e, args|
    next unless e.author.id == owner
    begin
        o = eval args.join(' ')
        e.respond "Evaled successfully.\n\n```#{o}```"
    rescue => err
        e.respond "Error.\n\n```#{err}```"
    end
end

bot.add_cmd(:ping, 'Pong?') do |e, args|
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

bot.add_cmd(:exit, 'Nooooo!') do |e, args|
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

bot.add_cmd(:help, '...') do |e, args|
    e.respond 'Nope.'
end

bot.add_cmd(:invoke, 'Manage Ruboat\'s invokers.') do |e, args|
    if args[0] != nil
        bot.do_subcmd(:invoke, args[0].to_sym, e, args)
    end
end

bot.add_cmd(:mod, 'Do moderative actions with Ruboat!') do |e, args|
    if args[0] != nil
        bot.do_subcmd(:mod, args[0].to_sym, e, args)
    end
end

bot.add_subcmd(:mod, :kick) do |e, args|
    heck = bot.parse_mention(args[0])
    raise Utils::UserError, 'Mention a valid member.' unless heck.is_a? Discordrb::User
    raise Utils::UserError, 'Insufficient permissions. You need "Kick Members".' unless e.author.permission? :kick_members
    user = heck.on(e.server)
    e.server.kick user
    e.respond ':ok_hand:'
end

bot.add_subcmd(:mod, :ban) do |e, args|
    heck = bot.parse_mention(args[0])
    raise Utils::UserError, 'Mention a valid member.' unless heck.is_a? Discordrb::User
    raise Utils::UserError, 'Insufficient permissions. You need "Ban Members".' unless e.author.permission? :ban_members
    user = heck.on(e.server)
    e.server.ban user
    e.respond ':ok_hand:'
end

bot.add_subcmd(:mod, :unban) do |e, args|
    raise Utils::UserError, 'Insufficient permissions. You need "Ban Members".' unless e.author.permission? :ban_members
    e.server.bans.each do |banne|
        if banne.username == args.join(' ')
            e.server.unban banne
            e.respond ':ok_hand:'
        end
    end
end

bot.add_cmd(:argtest, 'aaaaaaaa') do |e, args|
    p args
end

bot.add_cmd(:heck, 'aaaAAaaAaAaa') do |e, args|
    raise Utils::UserError, 'heck you'
end

bot.add_subcmd(:invoke, :list) do |e, args|
    e.respond "**RubyBoat Invokers**\n\n```\nPrefixes: #{@prefix.join(' | ')}\nSuffixes: #{@suffix.join(' | ')}```"
end

bot.add_subcmd(:invoke, :prefix) do |e, args|
    prefix = args.join ' '
    prefix = prefix.tr '"', ''
    prefix = prefix.tr "'", ''
    if !@prefix.include? prefix
        @prefix << prefix
        e.respond 'Added :ok_hand:'
    else
        @prefix.delete prefix
        e.respond 'Removed :ok_hand:'
    end
end

bot.add_subcmd(:invoke, :suffix) do |e, args|
    suffix = args.join ' '
    suffix = suffix.tr '"', ''
    suffix = suffix.tr "'", ''
    if !@suffix.include? suffix
        @suffix << suffix
        e.respond 'Added :ok_hand:'
    else
        @suffix.delete suffix
        e.respond 'Removed :ok_hand:'
    end
end

bot.add_cmd(:base64, 'Do stuff with Base64!') do |e, args|
    if args[0] != nil
        bot.do_subcmd(:base64, args[0].to_sym, e, args)
    end
end

bot.add_subcmd(:base64, :encode) do |e, args|
    text = args[1, args.length].join(' ')
    b64 = Base64.encode64(text).chomp
    e.respond "**Base64 Encode**\n\nYour encoded text is `#{b64}`"
end

bot.add_subcmd(:base64, :decode) do |e, args|
    text = args[1, args.length].join(' ')
    b64 = Base64.decode64(text).chomp
    e.respond "**Base64 Decode**\n\nYour decoded text is `#{b64}`"
end

bot.add_cmd(:error, 'ok') do |e, args|
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
        bot.do_cmd cmd, event, args
    end
    raw, cmd, args = check_suffix event.content, @suffix
    if cmd
        bot.do_cmd cmd, event, args
    end
end

bot.ready do
    puts 'bot ready'
    bot.game = "rb!invoke list | v#{version}"
end

## end hecking command framework ##

bot.run

# </ryware>
