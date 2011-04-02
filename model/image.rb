require 'RMagick'
require 'open-uri'

module Model
  class Image
    EXPIRED_TIME = 300
    
    def self.get_image(url)
      open(url).read
    end
    
    def self.vibrate(path, width, delay)
      ext = File.extname path
      base = File.basename path, ext
      filename = "tmp/#{base}-w#{width}-d#{delay}.gif"
      dist = "public/#{filename}"
      if File.exist?(dist)
        return filename if Time.now - File.mtime(dist) < EXPIRED_TIME
      end
      
      src = "public/tmp/#{File.basename path}"
      File.open(src, "wb"){|f|
        f.write open(path).read
      }
      img = Magick::Image.read(src).first
      gif = Magick::ImageList.new
      gif << img
      gif << img.roll(width, 0)
      gif = gif.deconstruct
      gif.delay = delay
      gif.coalesce
      gif.write dist
      filename
    end

  end
end
