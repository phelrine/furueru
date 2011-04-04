require 'RMagick'
require 'open-uri'

module Model
  class Image
    EXPIRED_TIME = 300
    
    def self.get_image(url, dst)
      File.open(dst, "wb"){|f|
        f.write open(url).read            
      }
      Model.logger.info("get image #{url}")
      dst
    end
    
    def self.create_vibrate_image(width, delay, src, dst)
      gif = Magick::ImageList.new
      img = Magick::Image.read(src).first.resize(48, 48)
      gif << img
      gif << img.roll(width, 0)
      gif.iterations = 0
      gif.delay = delay
      gif = gif.deconstruct.coalesce
      gif.write dst
      Model.logger.info("create image #{dst}")
    end      

    def self.vibrate(path, prefix, width, delay)
      ext = File.extname(path)
      base = File.basename(path, ext)
      filename = "tmp/#{prefix}-#{base}-w#{width}-d#{delay}.gif"
      dst = "public/#{filename}"
      src = "public/tmp/#{prefix}-#{File.basename path}"
    
      if File.exist? dst
        Model.Cache.get_or_set("get-image-#{dst}", EXPIRED_TIME){
          self.get_image(path, src) 
        }
      else
        self.get_image(path, src) 
        Model::Cache.force_set("get-image-#{dst}", dst, EXPIRED_TIME)
      end
      
      if File.exist? dst
        Model::Cache.get_or_set("img-#{dst}", EXPIRED_TIME){
          self.create_vibrate_image(width, delay, src, dst)
        }
      else
        self.create_vibrate_image(width, delay, src, dst)
        Model::Cache.force_set("img-#{dst}", dst, EXPIRED_TIME)
      end
      filename
    end
  end
end
