require_relative '../app/app'

Dir[File.dirname(__FILE__) + '/mp3_server/*.rb'].each do |f|
  require f
end
