# Description:
#   piccole cose e easter egg di Asjon
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   grazie/bravo asjon - ringrazia asjon
#   hubot ringraziamenti - chiedi ad asjon quante volte è stato ringraziato
#   hubot sei ... - giudica asjon
#   hubot come ti hanno chiamato? - chiedi ad asjon come è stato giudicato
#   hubot saluta <utente> - saluta l'utente
#   ciao asjon - saluta asjon
#
# Author:
#   Enrico Fasoli (fazo96)
#   Ravinder Pal Singh
#   Leonardo Magon
#   Gabriele Della Torre
#

module.exports = (robot) ->
  # Ringraziamenti
  ringr = ['prego :)', "non c'è di che", "faccio solo il mio lavoro", "no problemo amigo", "non fate complimenti ;)"]
  grazie = (res) ->
    robot.brain.set 'ringraziato', (robot.brain.get('ringraziato') or 0) + 1
    res.send res.random ringr
  robot.hear /(?:grazie|bravo) (?:asjon|assa|assioni)/i, grazie
  robot.respond /grazie/i, grazie
  robot.respond /ringraziamenti/i, (res) ->
    res.send 'voi teneroni mi avete ringraziato ' + (robot.brain.get('ringraziato') or 0) + ' volte :)'
  # Richiami
  robot.respond /sei (?:(?:proprio|davvero|veramente|molto|un|una) )?(.+)/i, (res) ->
    nomi = robot.brain.get('nomi') or {}
    nomi[res.match[1]] ?= 0
    nomi[res.match[1]] += 1
    robot.brain.set 'nomi', nomi
  robot.respond /come ti hanno chiamato/i, (res) ->
    a = robot.brain.get('nomi') or {}
    l = []
    for i of a
      l.push a[i]+' volt'+(if a[i] is 1 then 'a' else 'e')+' '+i
    res.send 'mi hanno chiamato '+l.join(', ')
  # Altro
  robot.respond /saluta (.+)/i, (res) ->
    res.send 'ciao ' + res.match[1]
  robot.respond /spaca botilia/i, (res) ->
    res.send 'AMAZO FAMILIA'
  robot.hear /trogu/i, (res) ->
    res.send 'comprate le prevendite da Trogu!!!'
  robot.hear /sarte/i, (res) ->
    res.send 'gesùùùù!!!'
  robot.hear /lucca/i, (res) ->
    res.send 'a Lucca piacciono i Pony. gayyyyy!!'
  robot.hear /singh/i, (res) ->
    res.send 'Singh, non sei più l\'indiano di una volta...'
  robot.hear /gae/i, (res) ->
    res.send 'il Gae viene dal Molise... che non esiste... ahahah'
  robot.hear /magon/i, (res)->
    res.send 'non si chiama Magon, si chiama Leo!'
  robot.hear /dilda/i, (res)->
    res.send 'oplààààà'
  robot.respond /dove sei/i, (res) ->
    robot.http('http://canihazip.com/s')
      .get() (err, r, body) ->
        res.send 'dovrei essere a ' + body
  robot.respond /con chi stai parlando/i, (res) ->
    console.log res.message.user, res.message.room
    if res.message.user.name is res.message.room
      res.send 'sto parlando con te, '+res.message.user.name
    else
      res.send 'sto parlando in '+res.message.room+', '+res.message.user.name
  robot.respond /ti amo/i, (res) ->
    res.send 'anche io ti amo '+(res.message.user.name+' ' or '')+'<3'
  robot.respond /ti odio/i, (res) ->
    res.send 'ma cosa ho fatto di male '+(res.message.user.name or '')+'? :('
  robot.hear /(?:ehi|ciao|(?:bella(?: li)?)) (?:asjon|assa|assion|assioni(?:i|e))(?:!)?/i, (res) ->
    console.log res.match
    saluti = ['ciao', 'bella', 'è arrivato', 'eccolooo', 'dimmi', 'weeee', 'ehilà']
    res.send res.random(saluti)+' '+res.message.user.name+'!'
  robot.respond /secret-kill-code/i, (res) -> process.exit 0
