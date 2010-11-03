require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'pony'
require 'email_veracity'
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

    post '/s/gifts/thanks' do
      haml :"gifts/thanks"
    end

    get '/s/rsvp' do
      @errors = {}
      haml :rsvp
    end

    post '/s/rsvp/respond' do
      @errors = {}

      if !EmailVeracity::Address.new(params[:email]).valid?
        @errors[:email] = 1
      end
      if params[:name].strip.length == 0
        @errors[:name] = 1
      end
      if !(params[:response] == 'yes' || params[:response] == 'no')
        @errors[:response] = 1
      end

      if @errors.keys.length == 0
        mail = Pony.mail :to      => 'wedding@bla.ir',
                  :from    => "#{params[:name]} <#{params[:email]}>",
                  :subject => "RSVP: #{params[:response].upcase} from #{params[:name]}",
                  :body    => erb(:"rsvp/_email"),
                  :via     => :smtp,
                  :via_options => {
                      :address        => "smtp.sendgrid.net",
                      :port           => "25",
                      :authentication => :plain,
                      :user_name      => ENV['SENDGRID_USERNAME'],
                      :password       => ENV['SENDGRID_PASSWORD'],
                      :domain         => ENV['SENDGRID_DOMAIN']
                  }
        haml :"rsvp/#{params[:response]}"
      else
        haml :rsvp
      end
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
        path = (request.env['PATH_INFO'].split(/\//)[2] || []).map { |p| p.capitalize }.push("Tim and Debbie's Wedding")
        path[0].upcase! if path[0] == "Rsvp"  # a bit of hackery for the acronym
        path.join(" | ")
      end

      def current_section
        request.env['PATH_INFO'].split(/\//)[2] || "home"
      end

      def ticker_text
        the_day = Date.new(2010, 12, 29)
        if Date.today == the_day
          "Today's the day!"
        else
          diff = the_day - Date.today
          word = diff.abs == 1 ? "day" : "days"
          if diff > 0
            "Time is ticking away: only #{diff} more #{word} to go!"
          else
            "Debbie and Tim have now been married for #{diff.abs} happy #{word}."
          end
        end
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
      gifts << Gift.new("Cocktails by the pool in the sunshine", "What better way to enjoy the luxuary of Costa Rica than a pina colada while doing absolutely nothing, rexlaing by the pool?", 25)
      gifts << Gift.new("Champagne and canapes before dinner", "We'd like to start dinner in style with some delicious nibbles and a glass of the finest bubbly.", 30)
      gifts << Gift.new("Side-by-side massage", "A fabulous side-by-side massage for 2 to help us properly relax and get into the holiday groove.", 50)
      gifts << Gift.new("Zip line through the cloud forest", "We just cannot believe that it is possible to zip line through the cloud forest where we can see tree frogs, birds and other animals.  This one's not for the faint-hearted, as you whizz over the tree tops on high-tension cables.  That's ok - we're not faint of heart!", 80)
      gifts << Gift.new("Honeymoon suite upgrade", "How amazing would it be if we could upgrade to the honeymoon suite?  We would really enjoy the beautiful garden views and private outdoor jacuzzi that's for sure!", 200)
      gifts << Gift.new("First night candle-lit meal", "We'd love to have a traditional Costa Rican meal for 2 by candlelight on the first night of our honeymoon.", 30)
      gifts << Gift.new("Palo Verde and Rio Tempisque boat tour", "This would be a mammoth extravagance and an out-of-this world experience.  We'd get to go on both the peaceful Palo Verde and eventful Rio Tempisque boat safari tours where we might even be lucky enough to catch a glimpse of a white-faced Capuchin monkey.", 75)
      gifts << Gift.new("Hot springs experience", "A trip to Costa Rica wouldn't be complete without seeing the Arenal Volcano and experiencing the associated hot springs. The volcano is the most active volcano in the country, and one of the most active in the World.  Scary but exciting!", 90)
      gifts << Gift.new("Monteverde Skywalk", "The amazing Monteverde Skywalk where we will take an exhilarating guided walk through the famous cloud forest on canopy-level suspension bridges.   Perched atop the Tilarán Mountains, Monteverde’s super-lush forests are home to an array of wildlife that includes howler monkeys, colorful hummingbirds and resplendent quetzals.", 140)
      gifts << Gift.new("Pacfic sailing and snokelling", "We get to go on a sailing day on the Pacific Ocean with a spot of snorkling in the beautiful clear water thrown in.", 60)
      gifts << Gift.new("Hiking and biking Lake Arenal", "We'd like to enjoy a fantastic day's hiking and biking around the beautiful Lake Arenal in the Monteverde area of Costa Rica.", 40)
      gifts << Gift.new("Trip to the turtle rescue project", "The beaches of Costa Rica are the nesting grounds of thousands of turtles, which are under threat from egg poaching.  It would be fantastic to visit the sea turtle resuce project and see the wonderful work they do.", 35)
      gifts << Gift.new("Sea kayak around Tortuga Island", "Active people as we are, we'd love the chance to experience Costa Rica's exotic west coast from a kayak: paddling in calm water, passing fascinating islands and clambering ashore on untouched virgin beaches...", 90)
      gifts << Gift.new("Lunch amoung the markets of San Jose", "We love the thought of taking a trip to San Jose to experience the bustling markets and have a nice traditional lunch while watching the world go by.", 25)
      gifts << Gift.new("Boat trip along the Tortuguero Canals", "We want to see as much of the country as we can, so a trip to the Tortuguero Canals – equivalent to the Costa Rica's Amazon – will take us up jungle-lined waterways that are home to an array of wildlife to a remote village and sea-turtle nesting beach.", 55)
      gifts << Gift.new("Holiday reading material", "Some holiday reading to keep us amused on those lazy mornings by the pool before a fun-packed day investigating Costa Rica.", 15)
      gifts << Gift.new("Horseback ride through Rincon de la Vieja", "There's only so much walking we can do, so how about a magnificent ride on horseback through the Rincon de la Vieja forest?", 60)
      gifts << Gift.new("Your own suggestion", "There must be hundreds of things that we've not thought of here, so if you have an idea of something exciting we can do that's not on the list, please suggest away!", 0)
      gifts
    end
  end

end


