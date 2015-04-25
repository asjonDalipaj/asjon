# Description:
#   utilità per il meteo
#
# Dependencies:
#   "moment":"2.10.2"
#
# Configuration:
#   None
#
# Commands:
#   hubot che tempo fa/c'è (a crema)? - guarda il cielo e risponde con informazioni sul meteo di crema
# 
# Author:
#   Enrico Fasoli (fazo96)

moment = require 'moment'

module.exports = (robot) ->
  robot.respond /che tempo(?: c'è| fa)?(?: a crema)?(?:\?)?/i, (res) ->
    url = 'http://api.openweathermap.org/data/2.5/weather?id=3177841&lang=it&units=metric'
    robot.http(url)
      .get() (err, r, body) ->
        try
          body = JSON.parse body
        catch e
          return res.send 'errore nel guardare il cielo.'
        alba = moment.unix(body.sys.sunrise).format('H:MM')
        tramonto = moment.unix(body.sys.sunset).format('H:MM')
        m = body.weather[0].description+' con '+body.main.humidity
        m += '% di umidità. Temperatura: '+body.main.temp+'°C. '
        m += "l'alba è alle "+alba+" mentre il tramonto alle "+tramonto
        res.send 'Meteo per Crema: '+m+'.'
