require_relative '../spec_helper'
require 'rack/test'

class MockController
  def show
    'HELLO!'
  end
end

class MockRequest
  attr_reader :request_method

  def initialize(method)
    @request_method = method
  end

  def path
    '/'
  end

  def params
    {
      'param1' => 'a'
    }
  end
end

describe 'router' do 
  def router
    Router.new
  end

  def controller
    MockController.new
  end

  def request
    MockRequest.new 'GET'
  end

  it 'responds with the appropriate controller method' do
    r = router
    r.register_route :get, '/', MockController, 'show'
    res = r.call request
    expect(res).to eq('HELLO!')
  end

  it 'raises exception if method doesn\'t exist' do
    r = router
    r.register_route :get, '/', MockController, 'LOL'
    expect { r.call request }.to raise_error(NoMethodError)
  end

  it 'raises exception if controller doesn\'t exist' do
    r = router
    expect { r.register_route :get, '/', NonexistentController, 'nothiin' }.to raise_error(NameError)
  end
end
