require_relative '../spec_helper'
require 'rack/test'
require 'open-uri'

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
    get '/dl', { 'host' => 'youtube.com', 'path' => '/watch', 'query' => 'v=out' }
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('audio/mpeg')
  end

  # these tests actually do a download, so we have to check if there's an internet connection
  def internet_connection?
    begin 
      true if open 'http://google.com'
    rescue
      false
    end
  end

  def do_if_internet(block)
    if @internet
      block.call
    else
      # if there's no internet, just automatically pass the tests
      p "No internet connection found.  Skipping download tests." if !@internet
      true
    end
  end

  it 'responds with "Say It" by Tory Lanez from youtube' do
    @internet = internet_connection?
    do_if_internet(Proc.new do 
      get '/dl', { 'host' => 'youtube.com', 'path' => '/watch', 'query' => 'v=xUq1rZ7mmns' }
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('audio/mpeg')
      expect(File.file?('public/mp3/xuq1rz7mmns.mp3')).to eq(true)
      expect(File.delete('public/mp3/xuq1rz7mmns.mp3')).to eq(1)
    end)
  end

  it 'responds with "thought it was a drought" by future from soundcloud' do 
    @internet = internet_connection?
    do_if_internet(Proc.new do 
      get '/dl', { 'host' => 'soundcloud.com', 'path' => '/lays-stay-kettle-cooked/future-thought-it-was-a-drought-dirty-sprite-2' }
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('audio/mpeg')
      expect(File.file?('public/mp3/lays-stay-kettle-cookedfuture-thought-it-was-a-drought-dirty-sprite-2.mp3')).to eq(true)
      expect(File.delete('public/mp3/lays-stay-kettle-cookedfuture-thought-it-was-a-drought-dirty-sprite-2.mp3')).to eq(1)
    end)
  end


end
