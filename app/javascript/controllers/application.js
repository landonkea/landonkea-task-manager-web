// Import the Application class from the Stimulus library, which is used to create and manage controllers
// Stimulus is a JavaScript framework that makes it easy to add behavior to HTML
import { Application } from "@hotwired/stimulus"

// Create a new instance of the Stimulus Application and start it
// This initializes the controller system and prepares it to handle DOM events
const application = Application.start()

// Configure Stimulus development experience
// Disable debug mode to reduce console output in production
application.debug = false

// Make the Stimulus application instance available globally on the window object
// This allows you to inspect and interact with Stimulus from the browser's console
window.Stimulus   = application

// Export the application instance so other modules can import and use it
// This is needed so controllers/index.js can access the same application instance
export { application }
