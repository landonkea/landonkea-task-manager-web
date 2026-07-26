# This file configures which request parameters are automatically hidden in log files.
# It's a security feature that prevents sensitive data (like passwords) from appearing
# in your logs, where they could be seen by anyone with access to the log files.

# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.

# `Rails.application.config.filter_parameters +=` adds to the list of parameters that Rails
# will automatically mask in log files. Any parameter whose NAME contains one of these
# keywords will have its value replaced with `[FILTERED]` in the logs.
Rails.application.config.filter_parameters += [
  # `:passw` matches any parameter containing "passw" -- catches "password", "password_confirmation",
  # "user_password", etc. You never want passwords appearing in logs.
  :passw,
  # `:email` filters email addresses from logs, protecting user privacy (PII protection).
  :email,
  # `:secret` catches parameters like "secret_key", "api_secret", etc. -- any secret values.
  :secret,
  # `:token` filters authentication tokens, API keys, and session tokens from logs.
  :token,
  # `:_key` catches parameters ending in "_key" like "access_key", "api_key", "secret_key".
  :_key,
  # `:crypt` filters encrypted or hashed values that might contain cryptographic material.
  :crypt,
  # `:salt` filters password salts -- random values used in password hashing that shouldn't leak.
  :salt,
  # `:certificate` filters SSL/TLS certificates and other sensitive certificate data.
  :certificate,
  # `:otp` filters One-Time Passwords (like 2FA codes) from logs.
  :otp,
  # `:ssn` filters Social Security Numbers (US government ID) from logs -- critical for compliance.
  :ssn,
  # `:cvv` filters credit card verification values -- the 3-digit code on the back of cards.
  :cvv,
  # `:cvc` is another name for card verification code (same as CVV, different card networks use different names).
  :cvc
]
