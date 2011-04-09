require 'RMagick'
require 'open-uri'

module Model
  class Image
    EXPIRED_TIME = 300
    
    def self.save_file(file, name)
      encode = name.crypt("change-me")
      Model::Cache.get_or_set("upload-file-#{encode}", EXPIRED_TIME){
        Model.logger.info "upload file: #{name}"
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
      dst
    end      

    def self.vibrate(path, width, delay)
      ext = File.extname(path)
      base = File.basename(path, ext)
      filename = "/tmp/#{base}-w#{width}-d#{delay}.gif"
      src = "public/#{path}"
      dst = "public/#{filename}"
      encode = path.crypt("change-me")
      
      if File.exist? dst
        Model::Cache.get_or_set("img-#{encode}", EXPIRED_TIME){
          self.create_vibrate_image(width, delay, src, dst)
        }
      else
        self.create_vibrate_image(width, delay, src, dst)
        Model::Cache.force_set("img-#{encode}", dst, EXPIRED_TIME)
      end
      filename
    end
  end
end
