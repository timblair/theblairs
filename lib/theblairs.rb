require 'rubygems'
require 'sinatra/base'
require 'erb'

module TheBlairs

  class Wedding < Sinatra::Base

    # using Sinatra::Base we'd normally have to specify this, but instead we'll use
    # Rack::Static (in config.ru) to bypass Sinatra completely for static files
    #set :static, true
    #set :public, File.dirname(__FILE__) + '/../public'

    get '/' do
      redirect '/s', 301
    end

    get '/s' do
      erb :index
    end

  end
end
