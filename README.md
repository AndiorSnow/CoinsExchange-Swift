# ReadMe

## App

- CoinsExchange gets a list of coins using https://api.coinranking.com/v2/coins and using https://api.coinranking.com/v2/coin/:uuid to introduces their detailed information.

## Build and Run

- Xcode 15.1 & Swift 5.9 Minimum version is iOS 17.2;

- Open CoinsExchange.xcworkspace

## Tech Stack

- Swift, UIKit, AutoLayout, Storyboard, Combine, UITableView, UICollectionView, URLSession and Kingfisher.

## Architecture

### MVVM Architecture

- ViewModel contains the business logic, requests data from the API using Combine;
- ViewModels communicate with the ViewController using Combine;
- ViewModel communicates with the API via Actions. Action is an abstraction to a Service.

### View Hierarchy

- Embeded UICollection View into custom cells of UITableView. The cell can be different kind of custom collection cells.
- Pull-up to loading. Loading 10 items of OtherCoinsCell or InviteFriendCell each time according to a certain pattern.

### CoinsService && CoinDetailService

- Responsible for communicating with the APIs and coordinating requests and responses.
- Uses DispatchQueue to perform the processing in the background, since the APIs are asynchronous and it shouldn't be run on the Main queue.
- CoinsResponse is a domain transfer object that's separate from the Coin model that the app is using. This is to allow for the API response to evolve in structure and data independent of the app's models.

### 3rd Party Dependencies

- CocoaPods for dependency management.
- Kingfisher 3rd party library for asynchronously fetching of images. This is done behind and UIImageView extension which makes it easier to swap it with a different 3rd party or refactor into something bespoke for the app.
- Combine framework provides a declarative Swift API for processing values over time. These values can represent many kinds of asynchronous events. Combine declares publishers to expose values that can change over time, and subscribers to receive those values from the publishers.

### Notes

- Uses Swift's Standard Library's Decodable and JSONDecoder for parsing.
