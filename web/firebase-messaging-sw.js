// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
firebase.initializeApp({
  apiKey: 'AIzaSyButRSOg3ZLUxB43gTaFBNvwQi5mzY-VZs',
  authDomain: 'safetyreportproject.firebaseapp.com',
  projectId: 'safetyreportproject',
  storageBucket: 'safetyreportproject.appspot.com',
  messagingSenderId: '54175991750',
  appId: '1:54175991750:web:d9bb5c79534e8153aa54c7',
  measurementId: 'G-WG2LE8CLYJ',
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// messaging.onBackgroundMessage((message) => {
//     console.log("onBackgroundMessage", message);
//   });

// // messaging.getToken ({vapidKey: "BGW04XbUXEZ6CfDXwTAPXn2XPhuNFSELmh5WqC1bccO4Kf0uU0Z2prX4mTvtjPej-64wOv8vlrKALskmjPZ0tPs"})
// messaging.getToken({ vapidKey: "BGW04XbUXEZ6CfDXwTAPXn2XPhuNFSELmh5WqC1bccO4Kf0uU0Z2prX4mTvtjPej-64wOv8vlrKALskmjPZ0tPs" }).then((currentToken) => {
//     console.log(currentToken);
//     document.querySelector('body').append(currentToken)
//     sendTokenToServer(currentToken)
// }).catch((err) => {
//     console.log(err);
//     // if error
//     setTokenSentToServer(false)
// })

// function sendTokenToServer(currentToken) {
//     if (!isTokenSentToServer()) {
//         console.log('Sending token to server ...');
//         setTokenSentToServer(true)
//     } else {
//         console.log('Token already available in the server');
//     }
// }
// function isTokenSentToServer() {
//     return window.localStorage.getItem('sentToServer') === '1'
// }
// function setTokenSentToServer(sent) {
//     window.localStorage.setItem('sentToServer', sent ? '1' : '0')
// }


// messaging.onMessage((payload) => {
//     console.log('Message received ', payload);
//     const messagesElement = document.querySelector('.message')
//     const dataHeaderElement = document.createElement('h5')
//     const dataElement = document.createElement('pre')
//     dataElement.style = "overflow-x: hidden;"
//     dataHeaderElement.textContent = "Message Received:"
//     dataElement.textContent = JSON.stringify(payload, null, 2)
//     messagesElement.appendChild(dataHeaderElement)
//     messagesElement.appendChild(dataElement)
// })

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});
