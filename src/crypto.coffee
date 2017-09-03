# Description:
#   Find the latest cryptocurrency's price in specified currency
#
# Commands:
#   (bch|btc|eth|ltc|xrp|zec) <target currency as 3 letters, defaults to USD>
#
# Author:
#   Jon Coe

GLOBAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
LOCAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/local/ticker/"  # TODO: try these two if not found at GLOBAL
CRYPTO_INDEX = "https://apiv2.bitcoinaverage.com/indices/crypto/ticker/"


module.exports = (robot) ->
  robot.respond /(eth|btc|bch|ltc|xrp|zec) ?(.*)/i, (msg) ->
    sourceCurrency = msg.match[1].trim().toUpperCase()
    targetCurrency = msg.match[2].trim().toUpperCase() || 'USD'
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

