require 'discordrb'

tk = "MzQ4MTIyNzY5MDcyMDYyNDc0.DHiWHA.jDV9sxAQcWrJX_5uyiGnebXBzQw"

bot = Discordrb::Commands::CommandBot.new token: tk, client_id: 348122769072062474, prefix: ['rb!', 'r!']

def truncate s, length = 30, ellipsis = '...'
  if s.length > length
    s.to_s[0..length].gsub(/[^\w]\w+\s*$/, ellipsis)
  else
    s
  end
end


bot.command :eval, help_available: false do |event, *code|
    break unless event.user.id == 190544080164487168
    begin
        e = eval code.join(' ')
        "Success!\n\n```\n#{e}```"
    rescue Exception => m
        "Oops. You did a bad.\n\n```\n#{m}```"
    end
end

bot.command :invite, help_available: true do |event|
    "ok, have my token because i don't know\n\n`#{bot.raw_token}`"
end

bot.command :setgame, help_available: true do |event, *game|
    bot.game = game.join ' '
    ':ok_hand:'
end

bot.command :ping, help_available: false do |event|
    event.respond "Pong! #{(Time.now - event.timestamp)}s"
end

bot.run