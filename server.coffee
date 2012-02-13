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
          options = read_id: card.read_key, trail: card.trail
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
    @scripts = [ '/leaflet/leaflet' ]
    @stylesheets = [ '/leaflet/leaflet' ]

    if @write_id?
      h1 'Thanks for scanning Jonathan Dahan\'s contact card'

      coffeescript ->
        window.onload = ->

          cloudmadeUrl = 'http://{s}.tile.cloudmade.com/9fee6b218cff45629803898d1a328cb3/997/256/{z}/{x}/{y}.png'
          cloudmadeAttribution = 'Map data &copy; 2012 OpenStreetMap contributors, Imagery &copy; 2012 CloudMade'
          cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18, attribution: cloudmadeAttribution})
          latlng = new L.LatLng(40.66, -73.98)
          map = new L.Map('map', {center: latlng, zoom: 15, layers: [cloudmade]})

          if navigator.geolocation?
            get_initial_position = (position) ->
              return if locationMarker
              locationMarker = new L.Marker new L.LatLng(position.coords.latitude, position.coords.longitude)
              map.addLayer locationMarker
              map.panTo locationMarker

            # grab the current location, as long as it takes less than 5 minutes and is no more than 15 minutes old
            navigator.geolocation.getCurrentPosition get_initial_position, (err) -> console.log("error #{err}"),
            timeout: (5 * 1000),
            maximumAge: (1000 * 60 * 15),
            enableHighAccuracy: true

            # update the marker if the position changes
            positionTimer = navigator.geolocation.watchPosition (position) ->
              locationMarker.setLatLng new L.LatLng position.coords.latitude, position.coords.longitude
              map.panTo locationMarker

            # clear the timer if the position doesn't change for 5 minutes
            setTimeout ->
              navigator.geolocation.clearWatch positionTimer
              , (1000 * 60 * 5)
    else
      h1 'Welcome back to Jonathan Dahan\'s contact card'
    p 'resume: http://jedahan.com/resume , portfolio: http://jedahan.jux.com'
    p 'email: jonathan@jedahan.com , twitter: @jedahan , phone: 631-332-8450'
    if @write_id?
      p 'Now that you have my contact information, the artifact has done its job'
      p 'Share it with others and see how far the trail goes!'
    h2 "Trail for #{@read_id}: #{@trail}"
    div id: 'map', style: 'height: 200px'
