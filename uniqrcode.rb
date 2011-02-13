#!/usr/bin/env ruby
# Copyright 2011 Jonathan Dahan <jonathan@jedahan.com>
# Distributed under the terms of the ICSL

def usage
" usage: #{$0} @url
result: a qrcode of @url/random-base64-uuid"
end

if ARGV.size==0
  print usage+"\n"
  exit
end

require 'uuidtools'
require 'rqrcode'
require 'chunky_png'

def uuid2url(uuid)
  hex2base64(uuid.gsub(/-/,'')).gsub(/[+\/]/,'+'=>'-','\/'=>'_').chop[0..-3]
end

def hex2base64(str)
  h1=[].clear
  16.times{ h1.push(str.slice!(0,2).hex) }
  [h1.pack("C*")].pack("m")
end

def qr2png(qr)
  @png = ChunkyPNG::Image.new(qr.module_count, qr.module_count, ChunkyPNG::Color::WHITE)

  qr.modules.each_index do |x|
    qr.modules.each_index do |y|
      qr.is_dark(x,y) and @png[x,y] = ChunkyPNG::Color::BLACK
    end
  end
  return @png
end

uuid = uuid2url(UUIDTools::UUID.random_create.to_s)
print ARGV.first + uuid + " => "
@png = qr2png( RQRCode::QRCode.new(ARGV.first+uuid, :size => 5, :level => :h) )
@png.save(uuid+'.png').to_s
print uuid + ".png\n"
