require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'pony'
require 'partials'

module TheBlairs

  class Wedding < Sinatra::Base

    # using Sinatra::Base we'd normally have to specify this, but instead we'll use
    # Rack::Static (in config.ru) to bypass Sinatra completely for static files
    #set :static, true
    #set :public, File.dirname(__FILE__) + '/../public'

    set :haml, { :format => :html5 }
    helpers Sinatra::Partials

    # common redirect points
    get '/' do redirect '/s', 301 end                       # index page is /s
	get %r{(.*)/$} do redirect params[:captures], 301 end   # remove trailing slashes

    get '/s' do
      haml :index
    end

    get '/s/gifts' do
      @gifts = Gift.all
      haml :gifts
    end

    post '/s/rsvp/respond' do
      Pony.mail :to      => 'tim@bla.ir',
                :from    => "#{params[:name]} <#{params[:email]}>",
                :subject => "RSVP: #{params[:response].upcase} from #{params[:name]}",
                :body    => erb(:"rsvp/_email")
      haml :"rsvp/#{params[:response]}"
    end

    get '/s/rsvp/respond' do
      redirect '/s/rsvp', 301
    end

    get '/s/*' do
      begin
        haml params["splat"].first.to_s.to_sym
      rescue
        raise $!
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


  class Gift
    attr_accessor :name, :info, :price

    def initialize(name, info, price)
      @name = name
      @info = info
      @price = price
    end

    def self.all
      gifts = []
      gifts << Gift.new("Cocktails by the pool in the sunshine", "", 25)
      gifts << Gift.new("Champagne and canapes before dinner", "", 30)
      gifts << Gift.new("Side-by-side massage", "", 50)
      gifts << Gift.new("Zip line through the cloud forest", "", 80)
      gifts << Gift.new("Honeymoon suite upgrade", "", 200)
      gifts << Gift.new("First night candle-lit meal", "", 30)
      gifts << Gift.new("Palo Verde boat tour", "", 75)
      gifts << Gift.new("Rio Tempisque boat tour", "", 75)
      gifts << Gift.new("Hot springs experience", "", 90)
      gifts << Gift.new("Monteverde Skywalk", "", 140)
      gifts << Gift.new("Pacfic sailing and snokelling", "", 60)
      gifts << Gift.new("Hiking and biking Lake Arenal", "", 40)
      gifts << Gift.new("Trip to the turtle rescue project", "", 35)
      gifts << Gift.new("Sea kayak around Tortuga Island", "", 90)
      gifts << Gift.new("Lunch amoung the markets of San Jose", "", 25)
      gifts << Gift.new("Boat trip along the Tortuguero Canals", "", 55)
      gifts << Gift.new("Holiday reading material", "", 15)
      gifts << Gift.new("Horseback ride through Rincon de la Vieja", "", 60)
      gifts << Gift.new("Your own suggestion", "", 0)
      gifts
    end
  end

end


