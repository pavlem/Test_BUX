# BUX Instructions
Install cocoa pods (there is only one library for web sockets) and start the **TBux.xcworkspace**. Also,  add your bundle ID to build on a real iPhone device. 
 
# User Interface:
 
First screen is just a start screen, tap on the **start** button and the Table View with a list of BUX products will appear (this is a real start of the app and the start screen is just for illustration purposes and NOT part of the app itself). 
 
Product list screen:
* Products (stocks) are searchable by name (just drag down and search bar will appear). 
* Every cell has a product name and the price (coloured to match the growth). Red for lower price, green for higher and grey for the same as the previous day's price. 
* On product tap we have a detail screen pushed for the selected product (push is done in a custom way, not the default one)
* For no internet case, you cannot continue and there is an alert message
* Portrait and landscape mode are supported. 
 
Product Details Screen:
* Product detail screen has some data about the stock. There is a blocking screen to illustrate slow connections UI. 
* We have **Connect** and **Start live monitoring** buttons which we need to tap to connect to the web socket and then to subscribe/unsubscribe to the desired channel respectively. 
* Also we have color indication for the connection status and the stock price (green, red or gray) depending on the previous stock price (has it risen or not) 
* There is support for no internet case when someone tries to tap one of the buttons and if there is live monitoring in progress they will stop
* Portrait and landscape mode are supported 
 
# Architecture:
* MMVM used as an app design pattern since it complements apples native, out of the box, MVC for UIKit and it's new MVVM in SwiftUI
* Networking module is independent and can be implemented anywhere. It is based on apple’s “URLSession”, generics and no third party libs
* There are Unit tests for view models and moc JSON of products list and details
* Custom navigation push is implemented (fade in)
* Reusable components have been made 
* File organisation: 
    * App - App related data
    * Components - reusable components like button, “BuxBtn.swift” and so on…
    * Sections - sections of the app which contain ViewControllers, ViewModels and Views
    * Lib - all custom made libraries with the main one being the networking module under “Networking” 
    * Resources - storyboards, strings, images
    * Vendors - third party classes - in our case there is only one and it's reachability 
