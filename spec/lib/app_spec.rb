require_relative '../spec_helper'
require 'rack/test'

describe 'mp3 server app' do
  include Rack::Test::Methods

  def app
    Mp3ServerApp.new
  end

  it 'gets an html index' do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('text/html')
  end

  it 'responds with an mp3 file for a found file' do
    post '/', { :f => 'out.mp3' }
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('audio/mpeg')
  end
end
