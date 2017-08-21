require 'discordrb'

class Utils
  class CommandArgError < StandardError; end
end

module UtilMethods
  def do_error_embed(heck, event)
    if heck.is_a? self.CommandArgError
        event.channel.send_embed('') do |embed|
            embed.title = 'Incorrect command arguments.'
            embed.description = 'This is *your* fault. Don\'t report this as a bug.'
            embed.colour = 0xFF0000
            embed.add_field(name: 'What you did wrong (aka Error Info)', value: "```\n#{err}```")
        end
      else
        event.channel.send_embed("") do |embed|
            embed.title = "An error occurred."
            embed.description = "In essence, Ry is bad. Just... go ahead and tell him or something."
            embed.colour = 0xFF0000
            embed.add_field(name: "Error info", value: "```\n#{a}```")
        end
      end
  end
end