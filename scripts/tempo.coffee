moment = require 'moment'
moment.locale 'it'

module.exports = (robot) ->
  robot.respond /quanto manca (?:al)? (\d+-\d+-\d+)(?:\?)?/, (res) ->
    m = moment(res.match[1],'YYYY-MM-DD').fromNow()
    res.send 'il '+res.match[1]+' è '+m
