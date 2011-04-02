require 'RMagick'

module Model
  class Image
    EXPIRED_TIME = 300
    
    def self.get_image(url)
      open(url).read
    end
    
    def self.vibrate(path, width, delay)
      ext = File.extname path
      base = File.basename path, ext
      filename = "generate/#{base}-w#{width}-d#{delay}.gif"
      dist = "public/#{filename}"
      
      if File.exist?(dist)
        return filename if Time.now - File.mtime(dist) < EXPIRED_TIME
      end

      img = Magick::Image.read("public/#{path}").first
      gif = Magick::ImageList.new
      gif << img
      gif << img.roll(width, 0)
      gif = gif.deconstruct
      gif.delay = delay
      gif.coalesce
      gif.write "public/#{filename}"
      filename
    end
  end
end
