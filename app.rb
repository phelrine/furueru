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
    raise "Capacity Over" if request.content_length.to_i > 1024 * 30
    raise "File is Empty" if params.empty?
    file = params[:upfile]
    type = file[:type]
    raise "Unsupport File" unless ["png","gif","jpg"].map{|s| "image/".concat(s)}.include? type
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
    File.cp src, dst
    content_type :gif
    send_file dst
  end
end
