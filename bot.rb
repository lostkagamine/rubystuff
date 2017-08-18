require 'discordrb'

tk = open("token").read

bot = Discordrb::Bot.new token: tk, client_id: 348122769072062474

puts "Bot invite link: #{bot.invite_url}"

prefix = 'rb!'

bot.message do |event|
    if event.content.start_with? prefix
        # it's a command
        cmd = event.content[prefix.length, event.content.length]
        cnts = event.content.split(' ')
        puts cmd
        puts cnts
        if cmd == 'hello'
            event.respond 'Hello Ruby!'
        end
        if cmd == 'eval'
            code = cnts[1, cnts.length]
            break unless event.user.id == 190544080164487168
            begin
                e = eval code.join(' ')
                event.respond "Success!\n\n```\n#{e}```"
            rescue Exception => m
                event.respond "Oops. You did a bad.\n\n```\n#{m}```"
            end
        end
        if cmd == 'quit'
            break unless event.user.id == 190544080164487168
            event.respond 'You\'re mean. :('
            quit
        end
    end
end

bot.run