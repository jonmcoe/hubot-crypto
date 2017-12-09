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


```
hubot gdax <source_currency> <target_currency>
```
Will fetch prices from GDAX for the limited set of (BTC|ETH|LTC) --> (USD|EUR)


### Examples
```
robot> robot btc
robot> BTC in USD: 14355.5 | 24hr change: -1690.34 (-10.53%) | Vol: 179634.38822293

robot> robot eth eur
robot> ETH in EUR: 393.8701 | 24hr change: +10.31 (+2.6883%) | Vol: 1017775.3482468

robot> robot xrp arf
robot> Could not find XRP in terms of ARF

robot> robot crypto omg
robot> OMG in BTC: 0.00058677 | 24hr change: +0.00007204 (+13.99513487%) | Vol: 207497.24702385

robot> robot crypto dash usd
robot> DASH in USD: 700.0112 | 24hr change: +2.4453 (+0.3505%) | Vol: 2493.51427182

robot> robot gdax ltc
robot> LTC in USD on GDAX: 149.49000000
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
