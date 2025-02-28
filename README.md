### CoinExchange
- XCode 12.4
- Swift + UIKit + MVVM + Combine
- Third party library: Kingfisher
- Get data to display from the API below and support multi screen size.
- Display coin detail when clicking the coin item.
- When scroll to the bottom page can get the next coins to display (10 items).
- Pull to refresh data.
- Display top 3 of coins by rank at the top section when searching this section isn’t displayed.
- Display the invite your friends to join us view at the position 5, 10, 20, 40, 80, 160, ... and can to share for invite your friends.
API Document: https://developers.coinranking.com/api/documentation/coins
API (v.2):
- Get coins : /v2/coins
- Search : /v2/coins?search={ :keyword }
- Coin detail : /v2/coin/{ :uuid }
