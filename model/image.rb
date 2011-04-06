require 'RMagick'
require 'open-uri'

module Model
  class Image
    EXPIRED_TIME = 300
    
    def self.save_file(file, name)
      Model::Cache.get_or_set("upload-file-#{name}", 300){
        filename = "tmp/#{Time.now.to_i}-#{name}" 
        dst = "public/#{filename}"
        open(dst, "wb"){|f| 
          f.write file.read
        }
        filename
      }
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

    def self.vibrate(path, width, delay)
      ext = File.extname(path)
      base = File.basename(path, ext)
      p filename = "/tmp/#{base}-w#{width}-d#{delay}.gif"
      p src = "public/#{path}"
      p dst = "public/#{filename}"
      
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
