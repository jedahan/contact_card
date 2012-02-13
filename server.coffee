#### author
#
# Copyright 2011-2012 Jonathan Dahan <jonathan@jedahan.com>
# Distributed under the terms of the ICSL


mongolian = require 'mongolian'
db = new mongolian 'localhost/contact_cards'
cards = db.collection 'cards'

require('zappa') ->
  @enable 'default layout'
  @use 'bodyParser', 'methodOverride', @app.router, 'static'

  @get
    '/card/:id': ->
      cards.findOne { $or: [{read_key: @params.id}, {write_key: @params.id}] }, (err, card) =>
        if card?
          options = read_id: card.read_key, trail: card.trail, scripts: [ 'leaflet/leaflet' ], stylesheets: [ 'leaflet/leaflet' ]
          options['write_id'] = card.write_key if @params.id is card.write_key
          @render 'map', options
        else
          @send "Invalid card #{@params.id}"

  @put
    '/card/:id': ->
      cars.update {write_key: @params.id}, {$addToSet: {trail: {location: @params.location, note: @params.note}}}, (err, card) ->
        if card?
          @render map: {err, card}
        else
          @send "Invalid card #{@params.id}"

  @view map: ->
    if @write_id?
      h1 'Thanks for scanning Jonathan Dahan\'s contact card'
    else
      h1 'Welcome back to Jonathan Dahan\'s contact card'
    p 'resume: http://jedahan.com/resume , portfolio: http://jedahan.jux.com'
    p 'email: jonathan@jedahan.com , twitter: @jedahan , phone: 631-332-8450'
    if @write_id?
      p 'Now that you have my contact information, the artifact has done its job'
      p 'Share it with others and see how far the trail goes!'
    h2 "Trail for #{@read_id}: #{@trail}"
    div id: '#map', style: 'height: 200px'