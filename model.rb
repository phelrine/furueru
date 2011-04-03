require 'model/twitter_oauth'
require 'model/database'
require 'model/user'
require 'model/image'
require 'model/cache'
require 'model/history'
require 'logger'

module Model
  def self.logger
    @logger ||= Logger.new($stderr)
  end
end
