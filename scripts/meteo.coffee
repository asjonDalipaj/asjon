# Description:
#   utilità per il meteo
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot 
# 
# Author:
#   Enrico Fasoli (fazo96)

module.exports = (robot) ->
  robot.respond /che tempo(?: c'è| fa)?(?: a crema)?(?:\?)?/i, (res) ->
    res.send moment().format('dddd Do MMMM YYYY H:MM:SS')
