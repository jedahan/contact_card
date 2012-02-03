#### Contact
#
# This is Jonathan Dahan's Contact Card
#

#### Database
#
# cards: [ { read_key: uuid(), write_key: uuid(), trail: [ { location: location, note: string },... ] } } ]

#### Installation
#
# Contact requires [Node.js](http://nodejs.org/) (`brew install node`)
# and [npm](http://npmjs.org) (`curl http://npmjs.org/install.sh | sh`) for
# installation. Install the libraries with:
#
#     npm install
#     npm install supervisor -g
#     supervisor server.coffee

#### Libararies
#
# Express for easy routing, jade for easy html

express = require 'express'
jade = require 'jade'
mongolian = require 'mongolian'

app = express.createServer()

server = new mongolian
db = server.db 'contact_cards'
cards = db.collection 'cards'

app.get '/test', (req,res) ->
  res.send 'Hello World'

# Setup routes for every write and read id
cards.find({},{ write_id:1, read_id:1}).forEach (card) ->
  console.log card
  app.get "/c/#{card.write_id}", mark_trail(card.write_id)
  app.get "/c/#{card.read_id}", read_trail(card.read_id)

# get the location and an optional note, add it to the db
mark_trail = (id) ->
  location = navigator.geolocation.getCurrentPosition
  note = prompt 'leave a note here'
  cards.findOne { write_id: id }, (error, card) ->
    # TODO: write
    if error?
      console.log "  #{error}"
    else
      card.trail << { location: location, note: note }
      read_trail card.read_id

# show a google map with all locations and notes
read_trail = (id) ->
  # TODO: rewrite the history to show the current id
  # history.replace id

  # grab just the trail's history, TODO: pass to the template
  cards.find({ read_id: id }, { trail:1 }).toArray (error, trail) ->
    if error
      console.error "  #{error}"
    else
      console.log trail
      res.render 'map.jade', { trail: trail }

app.use express.static(__dirname + '/public')
app.use app.router
app.listen 8888
