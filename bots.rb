require 'twitter_ebooks'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  attr_accessor :original, :model, :model_path

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV['SOAP_BOT_CONSUMER_KEY']
    self.consumer_secret = ENV['SOAP_BOT_CONSUMER_SECRET']
  end

  def on_startup
    load_model!

    # Get the names of characters which can be replaced
    @characters = File.foreach('characters.txt').map { |line| line.chomp }

    # Get the eldritch words
    @eldritch = File.foreach('eldritch.txt').map { |line| line.split("\n") }

    scheduler.every '57m' do
      # Kept the character count down to leave room for long Lovecraft names
      statement = model.make_statement(100)

      words = statement.split(' ')
      @new_words = []

      # Replace some capitalised words with eldritch horror
      words.each_with_index do |word|
        # Only replace words half of the time
        @new_words << if rand > 0.5
                        word
                      else
                        # Separate punctuation and anything after it, like 's
                        word_bits = word.split(/(?<=\w)(?=[.,?':;])/)
                        # Check if word is on character list
                        if @characters.include?(word_bits[0])
                          # Replace the word with ELDRITCH HORROR
                          word_bits[0] = @eldritch.sample
                        end
                        # Re-add the punctuation
                        word_bits.join
                      end
      end

      # Create the new statement
      new_statement = @new_words.join(' ')

      # puts new_statement
      tweet(new_statement)
    end
  end

  private

  def load_model!
    return if @model

    @model_path ||= 'model/eastenders.model'

    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

# Make a MyBot and attach it to an account
MyBot.new('eldritchenders') do |bot|
  bot.access_token = ENV['SOAP_BOT_TOKEN']
  bot.access_token_secret = ENV['SOAP_BOT_TOKEN_SECRET']
end
