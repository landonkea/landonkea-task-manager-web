# This file configures Importmap, which is how Rails loads JavaScript without
# using Node.js or npm bundlers (like Webpack). It maps JavaScript package names
# to actual files, letting your browser download JS directly.

# Pin npm packages by running ./bin/importmap

# `pin "application"` tells Importmap to serve your `app/javascript/application.js` file.
# This is your main JavaScript entry point -- the first JS file the browser loads.
pin "application"

# `pin "@hotwired/turbo-rails"` maps the Turbo library to its minified JS file.
# Turbo makes your Rails app feel like a single-page app by intercepting link clicks
# and form submissions, updating only the parts of the page that changed (no full reloads).
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# `pin "@hotwired/stimulus"` maps Stimulus to its minified JS file.
# Stimulus is a JavaScript framework for adding interactivity to HTML pages
# (like dropdown menus, form validation, live search, etc.) with minimal code.
pin "@hotwired/stimulus", to: "stimulus.min.js"

# `pin "@hotwired/stimulus-loading"` maps the Stimulus auto-loading helper.
# This file automatically discovers and connects your controller files in `app/javascript/controllers/`
# to the correct HTML elements, so you don't have to manually register each controller.
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# `pin_all_from "app/javascript/controllers"` makes all JS files in the controllers folder
# available to import. The `under: "controllers"` part sets the import path prefix,
# so you'd import a file as "controllers/hello_controller" in your JS code.
pin_all_from "app/javascript/controllers", under: "controllers"
