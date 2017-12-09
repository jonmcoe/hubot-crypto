# Description:
#   Find the latest cryptocurrency's price in specified currency
#
# Configuration:
#   HUBOT_CRYPTO_SYNONYMS: a json object for setting synonyms for different currencies
#   HUBOT_DEFAULT_FIAT: in absence of a stated target currency, use this. if not set we use USD
#
# Commands:
#   hubot (bch|btc|eth|ltc|xrp|zec) <target currency, or default> - Display price of source crypto in terms of target currency
#   hubot crypto <source currency> <target currency, defaults to BTC> - Display price of source crypto in terms of target currency
#   hubot gdax (btc|eth|ltc) (usd|eur) - Display price of source crypto in terms of target fiat, as reported by GDAX's API
#
# Author:
#   Jon Coe

GLOBAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
LOCAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/local/ticker/"
CRYPTO_INDEX = "https://apiv2.bitcoinaverage.com/indices/crypto/ticker/"

GDAX_BASE_URL = "https://api.gdax.com/products/"

# json object. should use all caps for both keys and values, but usages in chat remain case-insensitive
# ex: HUBOT_CRYPTO_SYNONYMS='{"HONEYBADGER": 'BTC'} bc it doesn't give a shit
SYNONYMS_DICT = JSON.parse(process.env.HUBOT_CRYPTO_SYNONYMS or 'null') or {} 

# three digit code. use all caps. ex: 'GBP'
DEFAULT_FIAT = process.env.HUBOT_CRYPTO_DEFAULT_FIAT or 'USD'

# don't need to type "crypto" before these. presently the array of all currencies at GLOBAL_INDEX
SUPPORTED_TOPLEVEL_CRYPTOS = ['btc', 'eth', 'ltc', 'bch', 'xrp', 'zec']

module.exports = (robot) ->
  # top level support. no need to type "crypto" first
  synonyms_addition = Object.keys(SYNONYMS_DICT).join('|')
  synonyms_addition = if synonyms_addition == '' then '' else synonyms_addition + '|'
  matching_regexp = new RegExp('(' + synonyms_addition + SUPPORTED_TOPLEVEL_CRYPTOS.join('|') + ')($|( .*))', 'i')
  robot.respond matching_regexp, (msg) ->
    firstToken = msg.match[1].trim().toUpperCase()
    sourceCurrency = if firstToken of SYNONYMS_DICT then SYNONYMS_DICT[firstToken] else firstToken
    targetCurrency = msg.match[2].trim().toUpperCase() || DEFAULT_FIAT
    reportPrice(msg, sourceCurrency, targetCurrency)

  # lesser currencies require typing "crypto" first. for these, BTC is the default target currency
  robot.respond /crypto ([a-z0-9]+) ?(.*)/i, (msg) ->
    sourceCurrency = msg.match[1].trim().toUpperCase()
    targetCurrency = msg.match[2].trim().toUpperCase() || 'BTC'
    reportPrice(msg, sourceCurrency, targetCurrency)

  # GDAX. A far more limited set of currencies, but in volatile times it varies significantly from
  # the composite prices at bitcoinaverage.com and often many observers are particularly interested
  # in the coinbase/gdax prices
  robot.respond /gdax (BTC|LTC|ETH) ?($|USD|EUR)/i, (msg) ->
    DEFAULT_GDAX_FIAT = if DEFAULT_FIAT in ['USD', 'EUR'] then DEFAULT_FIAT else 'USD'
    sourceCurrency = msg.match[1].trim().toUpperCase()
    targetCurrency = msg.match[2].trim().toUpperCase() || DEFAULT_GDAX_FIAT
    reportPriceGDAX(msg, sourceCurrency, targetCurrency)



reportPrice = (msg, sourceCurrency, targetCurrency) ->
  lastPath = sourceCurrency + targetCurrency

  # attempt global index
  msg
    .http(GLOBAL_INDEX + lastPath)
    .get() (err, res, body) ->
      if (res.statusCode == 200)
        msg.send "#{buildMessageFromResponse(body, sourceCurrency, targetCurrency)}"
      else
        # attempt local index
        msg
          .http(LOCAL_INDEX + lastPath)
          .get() (err, res, body) ->
            if (res.statusCode == 200)
              msg.send "#{buildMessageFromResponse(body, sourceCurrency, targetCurrency)}"
            # attempt crypto index
            else
              msg
                .http(CRYPTO_INDEX + lastPath)
                .get() (err, res, body) ->
                    if (res.statusCode == 200)
                      msg.send "#{buildMessageFromResponse(body, sourceCurrency, targetCurrency)}"
                    # failure
                    else
                      msg.send "Could not find #{sourceCurrency} in terms of #{targetCurrency}"


buildMessageFromResponse = (body, sourceCurrency, targetCurrency) ->
  json = JSON.parse(body)
  last = json.last
  total_vol = json.volume
  dayChangeAbsolute = json.changes.price.day
  dayChangePercent = json.changes.percent.day

  # append + to positives
  dayChangeAbsolute = if dayChangeAbsolute > 0 then '+' + dayChangeAbsolute else dayChangeAbsolute
  dayChangePercent = if dayChangePercent > 0 then '+' + dayChangePercent else dayChangePercent

  # TODO: fix the annoying scientification notation happening for small numbers
  "#{sourceCurrency} in #{targetCurrency}: #{last} | 24hr change: #{dayChangeAbsolute} (#{dayChangePercent}%) | Vol: #{total_vol}"


reportPriceGDAX = (msg, sourceCurrency, targetCurrency) ->
  lastPath = sourceCurrency + '-' + targetCurrency + '/ticker'
  msg
    .http(GDAX_BASE_URL + lastPath)
    .get() (err, res, body) ->
      json = JSON.parse(body)
      msg.send("#{sourceCurrency} in #{targetCurrency} on GDAX: #{json['price']}")