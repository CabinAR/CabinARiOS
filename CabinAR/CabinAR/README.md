Ation Cable:
https://thoughtbot.com/blog/talking-to-actioncable-without-rails

Starstream:
https://github.com/daltoniam/Starscream

https://www.raywenderlich.com/861-websockets-on-ios-with-starscream

Safe Area:
https://medium.com/rosberryapps/ios-safe-area-ca10e919526f


App Overview:
1. Get location
https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
https://developer.apple.com/documentation/corelocation/getting_the_user_s_location

2. Get nearby spaces (all to begin with)
CabinARApi call to get spaces w/ lat and lon
UITableView of spaces

3. Pick a space
Load ARKit for that space, with a back button

4. get download that space, download all the markers for that space
Get all the published pieces from that space

5. Install those markers into ARKit
Kingisher to download and load markers

6. Load the appropriate Aframe for the markers, with the appropriate scale
Pass code through

7. Add in a settings page, allow the user to log in "login / change user" button - new page w/ username / password









Android App Overview:
1. Get location
2. Get nearby spaces
3. Pick a nearby space
4. 