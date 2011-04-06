require 'sinatra'
require 'bundler/setup'
require 'erb'
require 'model'
require 'logger'

class FurueruApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :show_exceptions, false
  set :logging, true
  use Rack::Session::Cookie, :secret => Model::TwitterOauth::CONSUMER_KEY
  
  helpers do
    alias_method :h, :escape_html

    def uri_encode(str)
      URI.encode str
    end
  end

  error do
    status 500
    Model.logger.warn request.env['sinatra.error'].message
    'sorry... '
  end

  get '/' do
    erb :index
  end

  post '/' do
    raise if request.content_length.to_i > 1024 * 10
    unless params.empty?
      file = params[:upfile]
      filename = "tmp/" + Time.now.strftime("%s") +
        File.basename(file[:filename])
      dst = "public/#{filename}"
      open(dst, "wb"){|f| 
        f.write file[:tempfile].read
      }
      JSON.unparse({
          :filename => filename, 
          :type => file[:type]
        })
    end
  end
  
  post '/furueru' do
    data = {}
    data[:image] = Model::Image.vibrate(
      params[:src],
      params[:width].to_i, 
      params[:delay].to_i,
      )
    content_type :json
    JSON.unparse(data)
  end
  
  post '/get_icon' do
    p "test"
    src = "public/#{params[:src]}"
    dst = "public/history/#{File.basename params[:src]}"
    File.rename src, dst
    content_type :gif
    send_file dst
  end
end
