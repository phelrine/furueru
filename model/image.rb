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
    
    def self.create_freeze_image(src, dst, compressed)
      img = Magick::Image.read(src).first
      res = img
      if compressed
        img = img.resize(40,40)
        res = img.border(4, 4, "rgb(0,0,0)").quantize(256, Magick::GRAYColorspace)
      else
        res = img.resize(48,48)
      end 
      res.write dst
      Model.logger.info("create image #{dst}")
    end
      
    def self.freeze(path, prefix,compressed)
      ext = File.extname(path)
      base = File.basename(path, ext)
      filename = "tmp/#{prefix}-#{base}-c#{compressed}.gif"
      dst = "public/#{filename}"
      src = "public/tmp/#{prefix}-#{File.basename path}"
    
      if File.exist? dst
        Model::Cache.get_or_set("get-image-#{dst}", EXPIRED_TIME){
          self.get_image(path, src) 
        }
      else
        self.get_image(path, src) 
        Model::Cache.force_set("get-image-#{dst}", dst, EXPIRED_TIME)
      end
      
      if File.exist? dst
        Model::Cache.get_or_set("img-#{dst}", EXPIRED_TIME){
          self.create_freeze_image(src, dst, compressed)
        }
      else
        self.create_freeze_image(src, dst, compressed)
        Model::Cache.force_set("img-#{dst}", dst, EXPIRED_TIME)
      end
      filename
    end
  end
end
