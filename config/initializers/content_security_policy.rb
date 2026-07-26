# This file configures Content Security Policy (CSP) headers for your Rails app.
# CSP is a security feature that tells the browser which resources (scripts, styles, images)
# are allowed to load, helping prevent cross-site scripting (XSS) attacks.

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Everything below is commented out because CSP is not enabled by default.
# You'd uncomment and customize these lines when you're ready to lock down security.

# Rails.application.configure do
#   `config.content_security_policy do |policy|` starts defining the CSP rules.
#   config.content_security_policy do |policy|
#     `policy.default_src :self, :https` sets the default rule: only allow resources
#     from the same server (:self) and over HTTPS (:https). This catches any resource
#     types you haven't explicitly configured.
#     policy.default_src :self, :https
#     `policy.font_src :self, :https, :data` allows fonts from your server, HTTPS URLs,
#     and inline data URIs (base64-encoded fonts embedded in CSS).
#     policy.font_src    :self, :https, :data
#     `policy.img_src :self, :https, :data` allows images from your server, HTTPS URLs,
#     and data URIs (base64-encoded images embedded in HTML/CSS).
#     policy.img_src     :self, :https, :data
#     `policy.object_src :none` blocks all plugins (Flash, Java applets, etc.).
#     These are legacy technologies and should never be needed.
#     policy.object_src  :none
#     `policy.script_src :self, :https` only allows JavaScript from your server and HTTPS URLs.
#     This prevents loading malicious scripts from other domains.
#     policy.script_src  :self, :https
#     `policy.style_src :self, :https` only allows CSS from your server and HTTPS URLs.
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # `policy.report_uri "/csp-violation-report-endpoint"` tells the browser where to send
#     # CSP violation reports. Useful for monitoring what's being blocked.
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   # A "nonce" is a random number generated fresh for each request. Only scripts/styles
#   # with the correct nonce are allowed to run, blocking all others.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
#   # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
#   # config.content_security_policy_nonce_auto = true
#
#   # Report violations without enforcing the policy.
#   # When true, the browser reports violations but still loads the blocked resource.
#   # Useful for testing your CSP rules before enforcing them.
#   # config.content_security_policy_report_only = true
# end
