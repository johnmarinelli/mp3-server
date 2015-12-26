use Rack::Static,
  :urls => ['/mp3'],
  :root => 'public'

require_relative 'app/app'

run Mp3ServerApp.new
