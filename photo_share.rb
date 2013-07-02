# Demo for uploading images to Cloudinary and sharing them in real-time using PubNub
# A simple Sinatra server code.
require "bundler/setup"
require "sinatra"
require "haml"
require 'sass'
require "logger"
require "active_support"
require "action_view"
require "cloudinary"
require "pubnub"

# PubNub's publish and subscribe keys of your PubNub's account.
PUBNUB_PUBLISH_KEY = ENV['PUBNUB_PUBLISH_KEY'] # Something like: 'pub-c-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
PUBNUB_SUBSCRIBE_KEY = ENV['PUBNUB_SUBSCRIBE_KEY'] # Something like: 'sub-c-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

# A name of the PubNub channel to publish and subscribe to.
PUBNUB_CHANNEL = 'cloudinary_photo_share'

# Initialize view helpers
helpers do
  include CloudinaryHelper
  def controller() nil end
  def config() nil end  
end

# Allow embedding in an iframe for demo purposes
configure do
  set :protection, :except => :frame_options
end

# Converting SASS files to CSS
get '/stylesheets/*.css' do
  content_type 'text/css', :charset => 'utf-8'
  filename = params[:splat].first
  sass filename.to_sym, :views => "#{settings.root}/views/sass"
end

# Render the main page using index.haml HTML template
get "/" do  
  @channel = PUBNUB_CHANNEL
  @subscribe_key = PUBNUB_SUBSCRIBE_KEY
  haml :index
end

# Message sharing via Ajax
post "/share" do
  if params[:photo_id].present?
    # Process and verify the received signed photo identifier
    preloaded = Cloudinary::PreloadedFile.new(params[:photo_id])         
    return { :success => false, :message => "Invalid upload signature" }.to_json if !preloaded.valid?
    
    # Intialize PubNub
    pubnub = Pubnub.new( :publish_key => PUBNUB_PUBLISH_KEY, :subscribe_key => PUBNUB_SUBSCRIBE_KEY )
    
    # Publish a message to the PubNub channel, including the identifier of the image uploaded to Cloudinary. 
    pubnub.publish({
      :channel => PUBNUB_CHANNEL,
      :message => {
        cloudinary_photo_id: preloaded.identifier,
        user: params[:user],
        message: params[:message],
        kind: params[:kind],
        time: Time.now.utc.iso8601
      },
      :callback => lambda { |x| $stderr.puts("Shared #{preloaded.public_id}: #{x}") }
    })
    content_type :json    
    { :success => true }.to_json
  end  
end

