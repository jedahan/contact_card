description
-----------

 scan, :D, share

This is how [I](http://jonathan.is) do contact cards.

creating a new contact card
---------------------------

`./create_contact_card.rb [prefix]` does a few things when invoked:

  1. generate a pair of url-friendly uuids to act as a read_id and write_id
  2. creates an qr code based on the write_uuid
  3. adds a new card to the mongodb collection 'cards'

Its up to you how to display or distribute the qr code. I chose moo.com for its super-cheap completely customizable card printing service, and laser etching since I am right by some awesome hackerspaces.


the cards collection
--------------------

The cards collection is just a collection of cards (*gasp*!), which is defined as:

    marker: { location: gps coordinates, note: string }
    card: { read_key: uuid, write_key: uuid, trail: [ marker, ... ] }


the web interface
-----------------

Displays a map of all the points that card has travelled. If it was just scanned (and thereforce contains a valid write_id), an optional form is exposed to write a note and ask for your location to append to the map.

This is easily breakable, but thats fine, I can chalk it up to emergent behavior if someone is interested enough to go all Xzibit on this art.

Using zappa in coffeescript with node-mongolian served by node.js . BUZZWORDS LEVEL 9! WOO!


todo
----

  * grab geolocation
  * draw map trails
  * add comments
  * generate silly trail name for each contact card
  * print more cards
  * separate api from app
  * have a flower or monster grow with each hit