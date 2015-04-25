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
#   hubot agenda (per il) (domani|il (data)) - controlla i compiti assegnati il giorno dato e l'agenda per quel giorno
#   hubot che compiti ci sono? - mostra i compiti assegnati durante l'ultima settimana
#
# Author:
#   Enrico Fasoli (fazo96)
#

Nightmare = require 'nightmare'
cheerio = require 'cheerio'
moment = require 'moment'

estraiCompiti = (compiti) ->
  extractorCompiti = ->
    col = $($('td',this).get(1)).text().trim()
    arr = col.split(/(?:\s+)Materia: /i)
    if $('td',this).get(1)?
      data: $($('td',this).get(0)).text().trim()
      text: arr[0], materia: arr[1]
    else {}
  $ = cheerio.load compiti
  return $('.result_table tr').map(extractorCompiti).get().filter (c) -> c.text?

estraiAgenda = (agenda) ->
  extractorAgenda = ->
    if $('td',this).get(1)?
      $($('td',this).get(1)).text().trim()
    else "(niente)"
  $ = cheerio.load agenda
  tab = $('.result_table tr').map(extractorAgenda).get()
  tab.splice 0, 2
  return tab

downloadAgenda = (day, cb) ->
  agenda = ""; compiti = ""
  loadHtml = -> document.body.innerHTML
  saveAgenda = (data) -> agenda = data
  saveCompiti = (data) -> compiti = data
  dayurl = moment(day,'YYYY-MM-DD').format('YYYY-M-D')
  n = new Nightmare()
    .goto('https://galilei-cr-sito.registroelettronico.com/login/')
    .type('#username',process.env.REGISTRO_USERNAME)
    .type('#password',process.env.REGISTRO_PASSWORD)
    .click('#btnLogin').wait().screenshot('file.png')
  if process.env.REGISTRO_ID_STUDENTE
    n.goto('https://galilei-cr-sito.registroelettronico.com/select-student/'+process.env.REGISTRO_ID_STUDENTE+'/')
  n.goto('https://galilei-cr-sito.registroelettronico.com/agenda/?d='+dayurl)
   .evaluate(loadHtml, saveAgenda)
   .goto('https://galilei-cr-sito.registroelettronico.com/tasks/')
   .evaluate(loadHtml, saveCompiti)
   .run (err,nightmare) ->
      if err then console.log err
      if agenda.length > 0
        tab = estraiAgenda agenda
        comp = estraiCompiti compiti
        cb tab, comp
      else []

getCompiti = (cb) ->
  compiti = ''
  loadHtml = -> document.body.innerHTML
  saveCompiti = (data) -> compiti = data
  n = new Nightmare()
  n.goto('https://galilei-cr-sito.registroelettronico.com/login/')
  n.type('#username',process.env.REGISTRO_USERNAME)
  n.type('#password',process.env.REGISTRO_PASSWORD)
  n.click('#btnLogin').wait().screenshot('file.png')
  if process.env.REGISTRO_ID_STUDENTE
    n.goto('https://galilei-cr-sito.registroelettronico.com/select-student/'+process.env.REGISTRO_ID_STUDENTE+'/')
  n.goto('https://galilei-cr-sito.registroelettronico.com/tasks/')
  n.evaluate(loadHtml, saveCompiti)
  n.run (err,nightmare) -> cb estraiCompiti compiti

cosaCePerIl = (day,res) ->
  unless process.env.REGISTRO_USERNAME and process.env.REGISTRO_PASSWORD
    return res.send 'non dispongo delle credenziali per il registro :('
  res.send 'aspetta che guardo l\'agenda per il '+day+' (potrei metterci fino a 3 minuti)'
  downloadAgenda day, (ag,comp) ->
    if ag.length is 0 and comp.length is 0
      res.send "non c'è niente segnato sull'agenda per il "+day
    else
      c = comp.filter (x) -> x.data is moment(day,'YYYY-MM-DD').format('DD-MM-YYYY')
      c = c.map (x) -> x.materia+': '+x.text
      res.send "Agenda del #{day}: "+ag.concat(c).join(', ')

module.exports = (robot) ->
  robot.respond /(?:guarda l')?agenda (?:per )?doma(?:ni)?/i, (res) ->
    cosaCePerIl moment().add(1, 'days').format('YYYY-MM-DD'), res
  robot.respond /(?:guarda l')?agenda (?:per il )?(\d+-\d+-\d+)/i, (res) ->
    cosaCePerIl res.match[1], res
  robot.respond /(?:che )?compiti(?: ci sono)?(?:\?)?/i, (res) ->
    res.send 'controllo compiti...'
    getCompiti (compiti) ->
      # tengo solo quelli per il futuro
      compiti = compiti.filter (c) ->
        moment(c.data,'DD-MM-YYYY').isAfter(moment().subtract(1,'weeks'))
      # trasformo in stringa
      compiti = compiti.map (c) ->
        [c.data,c.materia,c.text].join ' | '
      res.send compiti.join '\n'
