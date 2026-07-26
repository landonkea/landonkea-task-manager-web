// This line is a comment explaining this file's purpose:
// A service worker is a background script that runs independently of the page
// It can handle push notifications, caching, and offline functionality
// This example code shows how to process Web Push notifications
//
// self.addEventListener("push" listens for push notifications from a server
// When a push message arrives, this function runs automatically
// async (event) means this function handles the event asynchronously
// self refers to the service worker itself (not the web page)
self.addEventListener("push", async (event) => {
//   event.data.json() reads the push notification data sent from the server
//   The destructuring { title, options } extracts just those two properties
//   title is the notification headline, options contains body text, icons, etc.
  const { title, options } = await event.data.json()
//   event.waitUntil() tells the browser "don't close this service worker yet"
//   self.registration.showNotification() displays the actual notification on screen
//   title and options are passed to control what the notification looks like
  event.waitUntil(self.registration.showNotification(title, options))
})
//
// self.addEventListener("notificationclick" listens for when the user clicks a notification
// This lets you respond to clicks, like opening a specific page in the app
self.addEventListener("notificationclick", function(event) {
//   event.notification.close() dismisses the notification from the screen
//   This runs immediately when the user clicks - the notification disappears
  event.notification.close()
//   event.waitUntil() keeps the service worker alive while we handle the click
  event.waitUntil(
//     clients.matchAll() finds all open windows/tabs controlled by this service worker
//     { type: "window" } filters to only browser windows (not iframes or workers)
//     .then() runs code once we have the list of open windows
    clients.matchAll({ type: "window" }).then((clientList) => {
//       Loop through all open windows to find one that matches the notification's path
      for (let i = 0; i < clientList.length; i++) {
//         clientList[i] gets the current window in the loop
        let client = clientList[i]
//         new URL(client.url) parses the window's URL, .pathname gets just the path part
//         For example, "http://localhost:3000/tasks" becomes "/tasks"
        let clientPath = (new URL(client.url)).pathname
//
//         Check if this window is already on the page the notification links to
//         "focus" in client checks if the window can receive focus (become active)
        if (clientPath == event.notification.data.path && "focus" in client) {
//           client.focus() brings the existing window to the front
//           This avoids opening a duplicate tab if the user is already on that page
          return client.focus()
        }
      }
//
//       If no matching window was found, open a new one
//       clients.openWindow() opens a new browser tab/window at the given URL
//       event.notification.data.path is the URL stored when the notification was created
      if (clients.openWindow) {
        return clients.openWindow(event.notification.data.path)
      }
    })
  )
// })
})
