# This file defines the ApplicationMailer, which is the parent class for ALL email senders.
# Mailers in Rails are responsible for composing and sending emails — similar to how
# controllers handle web requests, but for emails instead.

# ApplicationMailer inherits from ActionMailer::Base, which provides all the core
# functionality for building and sending emails in Rails.
class ApplicationMailer < ActionMailer::Base
  # This sets the default "from" address for every email sent by your app.
  # You'd replace "from@example.com" with your real email address (like "noreply@yourapp.com").
  # Individual mailers can override this if needed.
  default from: "from@example.com"

  # This tells Rails to wrap all email content in the "mailer" layout file.
  # The layout adds common styling and structure around your emails,
  # just like a website layout wraps your page content.
  layout "mailer"
end
