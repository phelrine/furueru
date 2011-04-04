module Model
  class History
    def self.collection
      Model::Database.collection("history")
    end
    
    def self.new_history(data)
      %w{icon_image user_id screen_name}.map(&:to_sym).each{|key|
        raise "data must have #{key}" unless data.has_key? key
      }
      
      self.collection.insert({
          :user_id => data[:user_id],
          :screen_name => data[:screen_name],
          :icon_image => data[:icon_image],
          :date => Time.now,
        })
      
      Model.logger.info "create history"
    end
    
    def self.unique_user
      Model::Cache.get_or_set("unique-user", 300){
        self.collection.find({}, {:sort => [:date, :desc]}).to_a.map{|hist|
          self.new(hist)
        }.uniq
      }
    end
    
    def self.recent_user(count=50)
      self.unique_user[0, count]        
    end
    
    def hash
      self.user_id.hash
    end

    def eql?(comp)
      self.hash == comp.hash
    end
    
    def initialize(data)
      @data = data.symbolize_keys
    end
    
    def user_id
      @data[:user_id]
    end
    
    def screen_name
      @data[:screen_name]
    end

    def icon_image
      @data[:icon_image]
    end
  end
end
