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
#
# Author:
#   Jon Coe

GLOBAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
LOCAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/local/ticker/"
CRYPTO_INDEX = "https://apiv2.bitcoinaverage.com/indices/crypto/ticker/"

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
  tf_avg = json.averages.day
  ask = json.ask
  bid = json.bid
  last = json.last
  total_vol = json.volume

  "#{sourceCurrency} in #{targetCurrency}: #{last} (Ask: #{ask} | Bid: #{bid} | 24h: #{tf_avg} | Vol: #{total_vol})"
