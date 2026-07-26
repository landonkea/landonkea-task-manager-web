// Import and register all your controllers from the importmap via controllers/**/*_controller
// This comment explains that controllers are loaded automatically from the controllers directory

// Import the application instance from the application.js file
// We need this to register controllers with the correct Stimulus application
import { application } from "controllers/application"

// Import the eagerLoadControllersFrom function from Stimulus's loading module
// This function automatically discovers and loads all controller files in the specified directory
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Call the function to load all controllers from the "controllers" directory and register them with the application
// This means any file matching controllers/*_controller.js will be automatically available
eagerLoadControllersFrom("controllers", application)
