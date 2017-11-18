# Description:
#   Find the latest cryptocurrency's price in specified currency
#
# Commands:
#   (bch|btc|eth|ltc|xrp|zec) <target currency as 3 letters, defaults to USD>  # TODO get on help list
#
# Author:
#   Jon Coe

GLOBAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
LOCAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/local/ticker/"  # TODO: try these two if not found at GLOBAL
CRYPTO_INDEX = "https://apiv2.bitcoinaverage.com/indices/crypto/ticker/"

# json object. use all caps for both keys and values. 
# ex: HUBOT_CRYPTO_SYNONYMS='{"HONEYBADGER": 'BTC'} bc it doesn't give a shit
SYNONYMS_DICT = JSON.parse(process.env.HUBOT_CRYPTO_SYNONYMS or 'null') or {} 

# three digit code. use all caps. ex: 'GBP'
DEFAULT_FIAT = process.env.HUBOT_CRYPTO_DEFAULT_FIAT or 'USD'

# presently the array of all currencys at GLOBAL_INDEX. will need to change if someone ever performs the TODO above
SUPPORTED_CRYPTOS = ['btc', 'eth', 'ltc', 'bch', 'xrp', 'zec']

module.exports = (robot) ->
  synonyms_addition = Object.keys(SYNONYMS_DICT).join('|')
  synonyms_addition = if synonyms_addition == '' then '' else synonyms_addition + '|'
  matching_regexp = new RegExp('(' + synonyms_addition + SUPPORTED_CRYPTOS.join('|') + ')($|( .*))', 'i')
  robot.respond matching_regexp, (msg) ->
    firstToken = msg.match[1].trim().toUpperCase()
    sourceCurrency = if firstToken of SYNONYMS_DICT then SYNONYMS_DICT[firstToken] else firstToken
    targetCurrency = msg.match[2].trim().toUpperCase() || DEFAULT_FIAT
    reportPrice(msg, sourceCurrency, targetCurrency)

reportPrice = (msg, sourceCurrency, targetCurrency) ->
  lastPath = sourceCurrency + targetCurrency
  msg
    .http(GLOBAL_INDEX + lastPath)
    .get() (err, res, body) ->
      msg.send "#{getPrice(body, sourceCurrency, targetCurrency)}"

getPrice = (body, sourceCurrency, targetCurrency) ->
  try
    json = JSON.parse(body)
  catch error
    return "Could not find #{sourceCurrency} in terms of #{targetCurrency}"
  tf_avg = json.averages.day
  ask = json.ask
  bid = json.bid
  last = json.last
  total_vol = json.volume

  "#{sourceCurrency} in #{targetCurrency}: #{last} (Ask: #{ask} | Bid: #{bid} | 24h: #{tf_avg} | Vol: #{total_vol})"
