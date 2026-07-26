// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// This comment tells you where to configure the import map, which maps module names to actual files

// Import the Turbo library for Rails, which enables fast page updates without full reloads
// Turbo is used to make the app feel faster by only reloading parts of the page that change
import "@hotwired/turbo-rails"

// Import the controllers directory, which loads all Stimulus controllers for the application
// Stimulus controllers handle interactive behavior in the browser
import "controllers"
