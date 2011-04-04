require 'rubytter'

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
    end

    def initialize(data)
      @data = data.symbolize_keys
    end

    def get_access_token
      @access_token unless @access_token
      @access_token = Model::TwitterOauth.access_token(
        Model::TwitterOauth.consumer,
        self.access_token,
        self.access_secret
        )
    end
    
    def key 
      @data[:_id].to_s
    end
    
    def token
      Digest::SHA1.hexdigest(self.key + "change")
    end

    def rubytter
      unless @rubytter
        @rubytter = OAuthRubytter.new(get_access_token)
      end
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

    def vibrate(width, delay)
      Model::Image.vibrate(
        self.profile_image_url, 
        self.user_id,
        width, delay)
    end

    def mime_type(file)
      case 
      when file =~ /\.jpg/ then 'image/jpg'
      when file =~ /\.gif$/ then 'image/gif'
      when file =~ /\.png$/ then 'image/png'
      else 'application/octet-stream'
      end
    end

    def self.add_multipart_data(req, params)
      crlf = "\r\n"
      boundary = Time.now.to_i.to_s(16)
      req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      body = ""
      params.each{|key,value|
        esc_key = CGI.escape(key.to_s)
        body << "--#{boundary}#{crlf}"
        if value.respond_to?(:read)
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{crlf}"
          body << "Content-Type: #{mime_type(value.path)}#{crlf}#{crlf}"
          body << value.read
        else
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{crlf}#{crlf}#{value}"
        end
        body << crlf
      }
      body << "--#{boundary}--#{crlf}#{crlf}"
      req.body = body
      req["Content-Length"] = req.body.size
    end

    def update_profile_image(path)
      src = "public/#{path}"
      raise "File Not Found" unless File.exist? src
      hist = "history/#{self.user_id}-#{Time.now.to_i}.gif"
      dst = "public/#{hist}"
      File.rename(src, dst)
      res = nil
      icon = File.new dst
      url = URI.parse "http://api.twitter.com/1/account/update_profile_image.json" 
      Net::HTTP.new(url.host, url.port).start{|http|
        req = Net::HTTP::Post.new(url.request_uri)
        Model::User.add_multipart_data(req, :image => icon)
        Model::TwitterOauth.oauth_sign(req, get_access_token)
        res = http.request(req)
      }
      Model.logger.info "updated profile image"
      
      body = JSON::Parser.new(res.body).parse
      raise body['error'] unless res.code == "200"

      Model::History.new_history({
          :user_id => self.user_id,
          :screen_name => self.screen_name,
          :icon_image => hist,
        })
      body
    end
  end
end
