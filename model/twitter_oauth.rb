require 'oauth'

module Model
  class TwitterOauth
    CONSUMER_KEY, CONSUMER_SECRET = 
      open("#{File.dirname(__FILE__)}/oauth.txt").read.split("\n")
    
    def self.consumer
      OAuth::Consumer.new(
        CONSUMER_KEY,
        CONSUMER_SECRET,
        :site => 'http://api.twitter.com'
        )
    end
    
    def self.access_token(consumer, token, secret)
      OAuth::AccessToken.new(
        consumer, 
        token,
        secret
        )
    end

    def self.get_access_token(req_token, req_secret, oauth_token, oauth_verifier)
      request = self.request_token(req_token, req_secret)
      request.get_access_token(
        {},
        :oauth_token => oauth_token,
        :oauth_verifier => oauth_verifier
        )
    end
    
    def self.request_token(token, secret)
      request_token = OAuth::RequestToken.new(
        self.consumer,
        token,
        secret
        )
    end
    
    def self.get_request_token
      self.consumer.get_request_token(
        :oauth_callback =>
        "http://localhost:9393/callback"
        )
    end

    def self.oauth_sign(request, access_token)
      self.consumer.sign!(request, access_token)
    end
  end
end
