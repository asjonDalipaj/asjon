moment = require 'moment'

module.exports = (robot) ->
  robot.respond /che ore sono(?:\?)?/i, (res) ->
    res.send moment().format('dddd Do MMMM YYYY H:MM:SS')
