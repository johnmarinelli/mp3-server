use Rack::Static,
  :urls => ['/mp3'],
  :root => 'public'

require_relative 'lib/mp3_server/app'

run Mp3ServerApp.new
