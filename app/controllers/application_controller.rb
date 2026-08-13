# This file defines the ApplicationController, which is the parent class for ALL controllers.
# Any settings or methods defined here apply to every controller in your app automatically.

# ApplicationController inherits from ActionController::Base, which provides all the core
# Rails controller functionality — handling requests, rendering templates, redirects, etc.
class ApplicationController < ActionController::Base
  include Authentication
  # This line blocks old, outdated browsers from accessing your app.
  # "versions: :modern" means only modern browsers (that support features like webp images,
  # web push notifications, CSS nesting, etc.) are allowed in.
  # This saves you from having to build fallbacks for ancient browsers.
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # This tells Rails to send a "not modified" response (304) when the JavaScript import map changes.
  # Import maps control how your app loads JavaScript files. When they change, the browser
  # needs to re-download them. This line makes that process efficient by using HTTP caching (ETags).
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
