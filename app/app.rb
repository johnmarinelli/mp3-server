require 'json'
require_relative '../lib/mp3_server/router'

# require all controllers
Dir[File.dirname(__FILE__) + '/controllers/*.rb'].each do |f|
  require f
end

class Mp3ServerApp
  private
  attr_accessor :router

  public
  def initialize
    @router = Router.new
    @router.register_route :get, '/', IndexController, 'show'
    @router.register_route :get, '/dl', Mp3FileController, 'get_file'
  end

  def call(env)
    req = Rack::Request.new env
    @router.call req
  end
end
