require 'rubygems'
require 'sinatra/base'
require 'haml'

module TheBlairs

  class Wedding < Sinatra::Base

    # using Sinatra::Base we'd normally have to specify this, but instead we'll use
    # Rack::Static (in config.ru) to bypass Sinatra completely for static files
    #set :static, true
    #set :public, File.dirname(__FILE__) + '/../public'

    set :haml, { :format => :html5 }

    # common redirect points
    get '/'   do redirect '/s', 301 end
    get '/s/' do redirect '/s', 301 end

    get '/s' do
      haml :index
    end

    get '/s/*' do
      begin
        haml params["splat"].first.to_s.to_sym
      rescue
        not_found
      end
    end

    not_found do
      haml '404'.to_sym
    end

    error do
      haml '500'.to_sym
    end

    helpers do
      def page_title
        # build a page title from the URL, assuming we're serving from /s/... for sub-pages
        path = request.env['PATH_INFO'].split(/\//)[2..-1].map { |p| p.capitalize }.push("Tim and Debbie's Wedding")
        path[0].upcase! if path[0] == "Rsvp"  # a bit of hackery for the acronym
        path.join(" | ")
      end
    end

  end
end
