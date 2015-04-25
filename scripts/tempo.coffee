# Description:
#   utilità varie per gli orari e le date
#
# Dependencies:
#   "moment": "2.10.2"
#
# Configuration:
#   None
#
# Commands:
#  hubot che ore sono? - stampa informazioni su questo momento
#
# Author:
#   Enrico Fasoli (fazo96)

moment = require 'moment'

module.exports = (robot) ->
  robot.respond /che ore sono(?:\?)?/i, (res) ->
    res.send moment().format('dddd Do MMMM YYYY H:MM:SS')
