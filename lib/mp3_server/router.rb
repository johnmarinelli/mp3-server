class Router
  private
  attr_writer :routes

  public
  attr_reader :routes
  def initialize
    @routes = {
      :get => {},
      :post => {}
    }
  end

  # method: symbol, path: string, controller: string, method: string
  def register_route(method, path, controller, controller_method) 
    @routes[method.to_sym] =  {
      path.to_s => {
        :controller => controller.to_s,
        :method => controller_method.to_s
      }
    }
  end

  def call(req)
    method = req.request_method.downcase.to_sym
    path = req.path
    res = nil

    begin
      intent = @routes[method][path]
      controller = Object.const_get(intent[:controller]).new
      method = intent[:method]
      res = controller.send method
    rescue NoMethodError, NameError => e
      # TODO: handle error?
      raise e
    end

    res
  end
end
