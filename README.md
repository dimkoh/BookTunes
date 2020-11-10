# BookTunes

## Install Flutter
The project is based on flutter, which needs to be installed locally. (https://flutter.dev/docs/get-started/install)

## Create and Add Spotify API Tokens
For the Spotify Integration it is also necessary to add a .env file to the base of the project and add the following parameters:


CLIENT_ID=XXXXXXX

REDIRECT_URL=XXXXXXX

SECRET=XXXXXX


Where the XXXXXX are replaced with the client id, redirect url and secret created in the spotify developer program. (https://developer.spotify.com/)

## Install IDE / Build Tools
To build the project, Android Studio as well as XCode (only on MacOS) need to be installed to build the apps for Android and iOS respectively.
The chosen android package name and/or iOs bundle id need to be set in the spotify developer program according to the project settings for the iOS and/or Android projects, other wise Spotify will not authorize the connections. (https://developer.android.com/studio/build/application-id & https://medium.com/@devesu/how-to-change-bundle-identifier-of-ios-app-and-package-name-of-android-app-within-react-native-app-4fbdd6679aa2)

## Start the App
After all this setup is done, the project can be built in Android Studio or XCode and/or with the command "flutter run" while a smartphone is connected to the computer.
If you have never installed an application from an untrusted source on the smartphone, you might need to allow / trust the installation on your device.
In order to be able to control the Spotify playback, Spotify needs to be installed on the phone and have an account logged in.



 
 
