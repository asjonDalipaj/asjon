# Description:
#   si collega al registro elettronico e controlla l'agenda
#
# Dependencies:
#   "cheerio": "0.19.0"
#   "nightmare": "1.8.0"
#   "moment":  "2.10.2"
#
# Configuration:
#   REGISTRO_USERNAME - username per login al registro
#   REGISTRO_PASSWORD - password per login al registro
#
# Commands:
#   hubot cosa c'è per (domani|il (data))? - controlla agenda per la data richiesta
#
# Author:
#   Enrico Fasoli (fazo96)
#

Nightmare = require 'nightmare'
cheerio = require 'cheerio'
moment = require 'moment'

downloadAgenda = (day, cb) ->
  cbCalled = no
  htmlData = ""
  loadHtml = -> document.body.innerHTML
  saveHtml = (data) -> htmlData = data
  dayHasEvents = (b) ->
    unless b
      cbCalled = yes
      cb []
  n = new Nightmare()
    .goto('https://galilei-cr-sito.registroelettronico.com/login/')
    .type('#username',process.env.REGISTRO_USERNAME)
    .type('#password',process.env.REGISTRO_PASSWORD)
    .click('#btnLogin').wait()
  if process.env.REGISTRO_ID_STUDENTE
    n.goto('https://galilei-cr-sito.registroelettronico.com/select-student/'+process.env.REGISTRO_ID_STUDENTE+'/')
  n.goto('https://galilei-cr-sito.registroelettronico.com/agenda/?d='+day)
   .evaluate(loadHtml, saveHtml)
  n.run (err,nightmare) ->
    if err then console.log err
    if !cbCalled and htmlData.length > 0
      rowExtractor = ->
        if $('td',this).get(1)?
          $($('td',this).get(1)).text().trim()
        else "(niente)"
      $ = cheerio.load htmlData
      tab = $('.result_table tr').map(rowExtractor).get()
      tab.splice 0, 2
      cb tab

cosaCePerIl = (day,res) ->
  unless process.env.REGISTRO_USERNAME and process.env.REGISTRO_PASSWORD
    return res.send 'non dispongo delle credenziali per il registro :('
  res.send 'aspetta che guardo l\'agenda per il '+day+' (potrei metterci fino a 3 minuti)'
  downloadAgenda day, (data) ->
    if data.length is 0
      res.send "non c'è niente segnato sull'agenda per il "+day
    else
      res.send "ecco cosa c'è per doma: "+data.join('; ')

module.exports = (robot) ->
  robot.respond /cosa c'è per domani?/i, (res) ->
    cosaCePerIl moment().add(1, 'days').format('YYYY-MM-DD'), res
  robot.respond /cosa c'è per il (\d+-\d+-\d+)/i, (res) ->
    cosaCePerIl res.match[1], res
