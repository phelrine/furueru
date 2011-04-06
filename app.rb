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
    raise if params.empty?
    file = params[:upfile]
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
  
  post '/get_icon' do
    src = "public/#{params[:src]}"
    dst = "public/history/#{File.basename params[:src]}"
    File.rename src, dst
    content_type :gif
    send_file dst
  end
end
