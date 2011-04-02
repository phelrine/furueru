require 'rubytter'
require 'open-uri'

module Model
  class User
    def self.collection
      Model::Database.collection("user")
    end
    
    def self.find_by_user_id(user_id)
      data = self.collection.find_one({:user_id => user_id})
      return nil unless data
      self.new(data)
    end

    def self.new_user(data)
      %w{user_id screen_name access_token access_secret}.map(&:to_sym).each{|key|
        raise "data must have #{key}" unless data.has_key? key
      }
      self.collection.update({:user_id => data[:user_id]}, data, {:upsert => true})
      user = self.find_by_user_id(data[:user_id])
      open("public/#{user.image_path}", "wb"){|f|
        f.write Model::Image.get_image(user.profile_image_url)
      }
      user
    end
    
    def initialize(data)
      @data = data.symbolize_keys
    end

    def rubytter
      @rubytter unless @rubytter
      @access_token = Model::TwitterOauth.access_token(
        Model::TwitterOauth.consumer,
        self.access_token,
        self.access_secret
        )
      @rubytter = OAuthRubytter.new(@access_token)
    end
    
    def user_id
      @data[:user_id]
    end

    def screen_name
      @data[:screen_name]
    end
    
    def access_token
      @data[:access_token]
    end

    def access_secret
      @data[:access_secret]
    end

    def profile
      self.rubytter.user(self.screen_name).to_hash
    end

    def profile_image_url
      self.profile[:profile_image_url]
    end

    def image_path
      "icon/#{self.user_id}-#{File.basename self.profile_image_url}"
    end
    
    def vibrate(width, delay)
      Model::Image.vibrate(self.image_path, width, delay)
    end

    def update_profile_image(path)
    end
  end
end
