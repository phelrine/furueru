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

    def require_token
      params[:token] or halt 400, 'token required'
      params[:token] == current_user.token or halt 400, 'token not match'
    end

    def require_user 
      current_user or redirect '/'
    end

    def current_user
      @current_user if defined? @current_user
      return unless session[:user_id]
      @current_user = Model::User.find_by_user_id(session[:user_id])
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
  
  get '/oauth' do
    request_token = Model::TwitterOauth.get_request_token
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect request_token.authorize_url
  end

  get '/callback' do
    access_token = Model::TwitterOauth.get_access_token(
      session[:request_token],
      session[:request_secret],
      params[:oauth_token],
      params[:oauth_verifier]
      )
    session.delete(:request_token)
    session.delete(:request_secret)
    
    user = Model::User.new_user({
        :user_id => access_token.params[:user_id],
        :screen_name => access_token.params[:screen_name],
        :access_token => access_token.params[:oauth_token],
        :access_secret => access_token.params[:oauth_token_secret],
      })

    session[:user_id] = user.user_id
    redirect "/"
  end

  post '/furueru' do
    require_user
    require_token
    data = {}
    data[:image] = current_user.vibrate(params[:width].to_i, params[:delay].to_i)
    content_type :json
    JSON.unparse(data)
  end
  
  get '/updated' do
    require_user
    erb :update
  end

  post '/update' do
    require_user
    require_token
    return "error" unless defined? params[:path] 
    current_user.update_profile_image params[:path]
    redirect "/updated"
  end

  get '/logout' do
    session.delete(:user_id)
    redirect "/"
  end
end
