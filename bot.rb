require 'discordrb'

tk = open("token").read

bot = Discordrb::Bot.new token: tk, client_id: 348122769072062474

puts "Bot invite link: #{bot.invite_url}"

prefix = 'rb!'

bot.message do |event|
    if event.content.start_with? prefix
        # it's a command
        cmd = event.content[prefix.length, event.content.length]
        puts cmd
        if cmd == 'hello'
            event.respond 'Hello Ruby!'
        end
    end
end

bot.run