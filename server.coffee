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

# Add a route for every id pair
cards.find( {}, { write_id: 1, read_id: 1}).toArray((error, valid_ids) ->
  for write_id, read_id in valid_ids
    app.get '/card/:id(#{read_id})', (req, res) ->
      show_card(res, read_id, '')
    app.get '/card/:id(#{write_id})', (req, res) ->
      show_card(res, read_id, write_id)
    app.put '/card/:id(#{write_id})', (req, res) ->
      mark_trail(res, write_id, req.body.location, req.body.note)
)

# Accept put, adds location and note to the trail
mark_trail = (res, id, location, note) ->
  cards.findOne { write_id: id }, (error, card) ->
    if error?
      console.log "  #{error}"
    else
      card.trail << { location: location, note: note }
      res.redirect "/c/#{card.read_id}"

# Render the current card trail and pass write_id if it exists
show_card = (res, id, write_id) ->
  cards.find({ read_id: id }, { trail:1 }).toArray (error, card) ->
    if error
      console.error "  #{error}"
    else
      card.write_id = write_id if write_id?
      res.render 'map.jade', { locals: { card: card } }

app.use express.static(__dirname + '/public')
app.use app.router
app.use express.bodyParser()
app.use express.methodOverride()
app.listen 8888
