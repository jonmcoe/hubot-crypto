## hubot-crypto

### Usage
```
hubot <crypto>			returns price of crypto in USD
hubot <crypto> <base>		returns price of crypto in base currency
```

Choices for `crypto`: bch, btc, eth, ltc, xrp, zec

Choices for `base`: btc, nearly any three digit code for a fiat

### Examples
```
robot> robot btc
robot> BTC in USD: 4473.06 (Ask: 4474.86 | Bid: 4467.96 | 24h: 4606.01 | Vol: 89950.25)

robot> robot eth eur
robot> ETH in EUR: 288.08 (Ask: 288.11 | Bid: 287.91 | 24h: 295.22 | Vol: 705055.02074735)
```

### Thanks to
https://github.com/github/hubot-scripts/blob/master/src/scripts/bitcoin.coffee

https://github.com/notpeter/hubot-bitcoin

Not exactly a fork, but I definitely took some guidance from both of the above
