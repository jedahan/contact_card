require 'sinatra'
require 'sqlite3'
require 'erb'

$qrcodes = SQLite3::Database.open( "qrcodes.db" )

$qrcodes.execute('select * from access') do |write,read|

  get '/'+read do
    p locations = db.execute("select * from trail where id=?", read)
    locations.empty? and p "how did you get to an empty trail?"
  end

  get '/'+write do
    point    = Struct.new :x, :y
    location = point.new(100,200)
    comment  = "test comment"

    $qrcodes.execute("insert into trail (x, y, comment) values (?, ?, ?)", location.x, location.y, comment )

    erb :scan

  end

end
