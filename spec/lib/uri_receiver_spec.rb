require_relative '../spec_helper'
require 'rack/test'

describe 'mp3 server app' do
  include Rack::Test::Methods

  def uri_receiver
    UriReceiver.new
  end

  it 'returns a valid URI given only host' do
    params = {
      'host' => URI.encode_www_form_component('google.com'),
    }

    uri = uri_receiver.get_uri params
    expect(uri.host).to eq('google.com')
  end

  it 'returns a valid URI given host, path' do
    params = {
      'host' => URI.encode_www_form_component('google.com'),
      'path' => URI.encode_www_form_component('/lol')
    }

    uri = uri_receiver.get_uri params
    expect(uri.host).to eq('google.com')
    expect(uri.path).to eq('/lol')
  end

  it 'returns a valid URI given host, path, and query' do
    params = {
      'host' => URI.encode_www_form_component('google.com'),
      'path' => URI.encode_www_form_component('/lol'),
      'query' => URI.encode_www_form_component('a=b&c=d')
    }

    uri = uri_receiver.get_uri params
    expect(uri.host).to eq('google.com')
    expect(uri.path).to eq('/lol')
    expect(uri.query).to eq('a=b&c=d')
  end

  it 'returns a valid URI given BAD host, path, and query' do
    params = {
      'host' => URI.encode_www_form_component('google.com////////'),
      'path' => URI.encode_www_form_component('/lol'),
      'query' => URI.encode_www_form_component('a=b&c=d')
    }

    uri = uri_receiver.get_uri params
    expect(uri.host).to eq('google.com')
    expect(uri.path).to eq('/lol')
    expect(uri.query).to eq('a=b&c=d')
  end

  it 'returns a valid URI given host, BAD (non-absolute) path, and query' do
    params = {
      'host' => URI.encode_www_form_component('google.com'),
      'path' => URI.encode_www_form_component('lol/bad'),
      'query' => URI.encode_www_form_component('a=b&c=d')
    }

    uri = uri_receiver.get_uri params
    expect(uri.host).to eq('google.com')
    expect(uri.path).to eq('/lol/bad')
    expect(uri.query).to eq('a=b&c=d')
  end
end
