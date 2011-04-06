require 'model/image'
require 'model/cache'
require 'logger'

module Model
  def self.logger
    @logger ||= Logger.new($stderr)
  end
end
