#!/usr/bin/env ruby
# Copyright 2011-2012 Jonathan Dahan <jonathan@jedahan.com>
# Distributed under the terms of the ICSL

require 'uuidtools'
require 'rqrcode'
require 'chunky_png'
require 'quick_magick'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['contact_cards']
$cards = @db['cards']

class ContactCard
  @@image_dir  = "images"
  @@pixel_size = 10

  # Create a pair of url friendly uuids
  def initialize (args)
    @write_key = uurid(UUIDTools::UUID.random_create.to_s)
    @read_key = uurid(UUIDTools::UUID.random_create.to_s)
    @png = qr2png( RQRCode::QRCode.new(args.first.to_s+@write_key, :size => 5, :level => :h), @@pixel_size )
    @png = glider_overlay(@png, @@pixel_size)
    @png.save(@@image_dir+'/'+@write_key+'.png', :fast_rgb)

    $cards.insert({ read_key: @read_key, write_key: @write_key, trail: [ ] } )
  end

  # Convert a uuid to a url-friendly, smaller format
  def uurid(uuid)
    # remove dashes
    str = uuid.gsub(/-/,'')
    # convert to base64
    h1  = [].clear
    16.times{ h1.push(str.slice!(0,2).hex) }
    str = [h1.pack("C*")].pack("m")
    # make url-friendly, remove the ==\n
    str.gsub(/[+\/]/,'+'=>'-','\/'=>'_').chop[0..-3]
  end

  def glider_overlay(png, resize)
    glider = [ [ 1, 1, 1, 1, 1, 1, 1 ],
               [ 1, 0, 0, 0, 0, 0, 1 ],
               [ 1, 0, 0, 1, 0, 0, 1 ],
               [ 1, 0, 0, 0, 1, 0, 1 ],
               [ 1, 0, 1, 1, 1, 0, 1 ],
               [ 1, 0, 0, 0, 0, 0, 1 ],
               [ 1, 1, 1, 1, 1, 1, 1 ] ]
    offset = (png.dimension.width/resize - glider.size) / 2

    glider.each_index do |x|
      glider.each_index do |y|
        color = glider[x][y]==1 ? ChunkyPNG::Color::rgb(255,0,0) : ChunkyPNG::Color::WHITE
        png.rect( (offset+y)   * resize,
                  (offset+x)   * resize,
                  (offset+y+1) * resize,
                  (offset+x+1) * resize, color, color)
      end
    end
    return png
  end

  def qr2png(qr,resize)
    png = ChunkyPNG::Image.new(qr.module_count*resize, qr.module_count*resize, ChunkyPNG::Color::WHITE)
    qr.modules.each_index do |x|
      qr.modules.each_index do |y|
        qr.is_dark(x,y) and png.rect(y*resize,x*resize,(y+1)*resize,(x+1)*resize,ChunkyPNG::Color::BLACK,ChunkyPNG::Color::BLACK)
      end
    end
    return png
  end
end

ContactCard.new(ARGV)
