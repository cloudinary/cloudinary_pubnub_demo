Cloudinary & PubNub Photo Sharing Demo
======================================

Demo for uploading images to Cloudinary and sharing them in real-time using PubNub.

Uses Sinatra as a thin Ruby server layer. Uses Cloudinary's Ruby GEM and jQuery plugin for performing direct image uploading from the browser, cloud-based image manipulations and optimized delivery through a CDN.
Uses PubNub's Ruby GEM and Javascript library for publishing messages, subscribing to a real-time channel and fetching message history.


**A live demo is available here**: http://cloudinary-pubnub-demo.herokuapp.com/

For more details about **Cloudinary**: http://cloudinary.com/

For more details about **PubNub**: http://www.pubnub.com/



## Installation

1. Create a **PubNub** account: http://www.pubnub.com/free-trial

2. Create a **Cloudinary** account: https://cloudinary.com/users/register/free

3. Download or clone sources, prepare a **Ruby** environment and go to the `server` folder.

4. Install the required Ruby GEMs by running `bundle install`.

5. Define the following environment variables with the keys and settings of your PubNub and Cloudinary accounts: `PUBNUB_PUBLISH_KEY`, `PUBNUB_SUBSCRIBE_KEY` and `CLOUDINARY_URL`. Alternatively, edit `photo_share.rb` and programmatically define your keys and settings.

6. Run a Thin web server: `thin start`.

7. Browse to `http://localhost:3000` in multiple browser windows, upload images and see the live photo sharing stream in action.


## How does it work?

1. Cloudinary's jQuery plugin is used to perform direct uploading to the cloud from the browser.
1. Signature for authorizing uploads to Cloudinary are generated on the server side and included in the HTML page.
1. Cloudinary's cloud-based transformations are applied: generating thumbnails using face detection based cropping, adding a watermark, applying effects.
1. Cloudinary's image identifier as well as user name and message are sent to the web server that securely publishes a real time message to a PubNub channel.
1. The web page uses PubNub's Javascript library to subscribe to a real-time live messaging channel shared by all users.
1. Messages received via PubNub are used to trigger the live shared photos stream's display.
1. The thumbnails and full-size images are generated and delivered through a fast CDN by Cloudinary. Image URLs are built using Cloudinary's jQuery plugin based on the identifier included in the PubNub message.
1. Previously published messages are also displayed on page loading using PubNub's History support.


## License

Released under the MIT license. 
