require 'discordrb'

class Utils
  class UserError < StandardError; end
end

module UtilMethods
  def self.do_error_embed(heck, event)
    if heck.is_a? Utils::UserError
        event.channel.send_embed('') do |embed|
            embed.title = 'User error.'
            embed.description = 'This is *your* fault. Don\'t report this as a bug.'
            embed.colour = 0xFF0000
            embed.add_field(name: 'What you did wrong (aka Error Info)', value: "```\n#{heck}```")
        end
      else
        event.channel.send_embed("") do |embed|
            embed.title = "An error occurred."
            embed.description = "In essence, Ry is bad. Just... go ahead and tell him or something."
            embed.colour = 0xFF0000
            embed.add_field(name: "Error info", value: "```\n#{heck}```")
        end
      end
  end
end