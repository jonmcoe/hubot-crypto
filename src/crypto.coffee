# Description:
#   Find the latest cryptocurrency's price in specified currency
#
# Commands:
#   (bch|btc|eth|ltc|xrp|zec) <target currency as 3 letters>
#
# Author:
#   Jon Coe

GLOBAL_INDEX = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"

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
  json = JSON.parse(body)
  tf_avg = json.averages.day
  ask = json.ask
  bid = json.bid
  last = json.last
  total_vol = json.volume
  false

  if tf_avg == null
    "Can't find the price for #{currency}. :("
  else
    "#{sourceCurrency} in #{targetCurrency}: #{last} (Ask: #{ask} | Bid: #{bid} | 24h: #{tf_avg} | Vol: #{total_vol})"

