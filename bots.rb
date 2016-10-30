require 'twitter_ebooks'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  attr_accessor :original, :model, :model_path

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV['SOAP_BOT_CONSUMER_KEY'] # Your app consumer key
    self.consumer_secret = ENV['SOAP_BOT_CONSUMER_SECRET'] # Your app consumer secret

    # Users to block instead of interacting with
    # self.blacklist = ['username']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup
    load_model!

    scheduler.every '1m' do
      statement = model.make_statement(140)
      tweet(statement)
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
MyBot.new('wikisoapbot') do |bot|
  bot.access_token = ENV['SOAP_BOT_TOKEN'] # Token connecting the app to this account
  bot.access_token_secret = ENV['SOAP_BOT_TOKEN_SECRET'] # Secret connecting the app to this account
end
