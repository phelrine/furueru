require 'sinatra'
require 'bundler/setup'
require 'erb'
require 'model'
require 'logger'
require 'json'

class FurueruApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :show_exceptions, false
  set :logging, true
  
  helpers do
    alias_method :h, :escape_html

    def uri_encode(str)
      URI.encode str
    end
  end

  error do
    status 500
    Model.logger.warn request.env['sinatra.error'].message
    'error...'
  end

  get '/' do
    erb :index
  end

  post '/' do
    if request.content_length.to_i > 1024 * 30
      Model.logger.warn "file size: #{request.content_length}"
      halt 500, "Capacity Over" 
    end
    if params.empty? || params[:upfile].empty?
      halt 500, "File is Empty" 
    end
    file = params[:upfile]
    type = file[:type]
    Model.logger.info "file type: #{type}"
    halt 500, "Unsupport File" unless ["png", "x-png", "gif", "jpeg", "pjpeg"].map{|s| 
      "image/".concat(s)
    }.include? type
    dst = Model::Image.save_file(file[:tempfile], File.basename(file[:filename]))
    JSON.unparse({
        :filename => dst,
        :type => file[:type]
      })
  end
  
  post '/furueru' do
    data = {}
    data[:image] = Model::Image.vibrate(
      params[:src],
      params[:width].to_i, 
      params[:delay].to_i
      )
    content_type :json
    JSON.unparse(data)
  end
  
  post '/download' do
    src = "public/#{params[:src]}"
    dst = "public/history/#{File.basename params[:src]}"
    FileUtils.cp src, dst
    Model.logger.info "copy file #{src} to #{dst}"    
    content_type :gif
    send_file dst
  end
end
