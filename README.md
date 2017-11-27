## hubot-crypto [![NPM version](https://badge.fury.io/js/hubot-crypto.png)](http://badge.fury.io/js/hubot-crypto)

### Usage
```
hubot <cryptocurrency>          returns price of cryptocurrency in USD (or configured default fiat)
hubot <cryptocurrency> <base>   returns price of cryptocurrency in base currency
```

Choices for `cryptocurrency`: bch, btc, eth, ltc, xrp, zec

Choices for `base`: btc, nearly any three character code for a fiat (USD, EUR, GBP, JPY, etc)

```
hubot crypto <source_currency> <target_currency>
```
Will attempt to find `source_currency` in terms of `target_currency` and includes a much wider set of choices for `source_currency`

See https://apiv2.bitcoinaverage.com/constants/symbols

### Examples
```
robot> robot btc
robot> BTC in USD: 4473.06 (Ask: 4474.86 | Bid: 4467.96 | 24h: 4606.01 | Vol: 89950.25)

robot> robot eth eur
robot> ETH in EUR: 288.08 (Ask: 288.11 | Bid: 287.91 | 24h: 295.22 | Vol: 705055.02074735)

robot> robot xrp arf
robot> Could not find XRP in terms of ARF

robot> robot crypto omg
robot> OMG in BTC: 0.00090207 (Ask: 0.00090211 | Bid: 0.00089637 | 24h: 0.00057462 | Vol: 214519.60318912)

robot> robot crypto dash usd
robot> DASH in USD: 622.89 (Ask: 622.89 | Bid: 619.1287 | 24h: 1061.8239 | Vol: 1754.80291928)
```

### Installation
1. cd into your hubot dir, run `npm install --save hubot-crypto` (adds it as a dependency in package.json).
2. Add `"hubot-crypto"` to your `external-scripts.json` file.
3. Restart Hubot.

Or just drop crypto.coffee into your hubot's scripts/ directory.


### Thanks to
https://github.com/github/hubot-scripts/blob/master/src/scripts/bitcoin.coffee

https://github.com/notpeter/hubot-bitcoin

Not exactly a fork, but I definitely took some guidance from both of the above
