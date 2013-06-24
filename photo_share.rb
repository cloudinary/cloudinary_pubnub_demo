require "bundler/setup"
require "sinatra"
require "haml"
require "logger"
require "active_support"
require "action_view"
require "cloudinary"
require "pubnub"


PUBNUB_PUBLISH_KEY = ENV['PUBNUB_PUBLISH_KEY'] # Something like: 'pub-c-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
PUBNUB_SUBSCRIBE_KEY = ENV['PUBNUB_SUBSCRIBE_KEY'] # Something like: 'sub-c-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

PUBNUB_CHANNEL = 'cloudinary_photo_share'

helpers do
  include CloudinaryHelper
end

get "/" do  
  @channel = PUBNUB_CHANNEL
  @subscribe_key = PUBNUB_SUBSCRIBE_KEY
  haml :index
end

post "/share" do
  if params[:photo_id].present?
    preloaded = Cloudinary::PreloadedFile.new(params[:photo_id])         
    raise "Invalid upload signature" if !preloaded.valid?
    
    pubnub = Pubnub.new( :publish_key => PUBNUB_PUBLISH_KEY, :subscribe_key => PUBNUB_SUBSCRIBE_KEY )
    pubnub.publish({
      :channel => PUBNUB_CHANNEL,
      :message => {
        cloudinary_photo_id: preloaded.identifier,
        user: params[:user],
        message: params[:message]
      },
      :callback => lambda { |x| $stderr.puts("Shared #{preloaded.public_id}: #{x}") }

    })
    content_type :json    
    { :success => true }.to_json
  end  
end
