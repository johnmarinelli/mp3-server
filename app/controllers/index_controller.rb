require_relative './base_controller'
require_relative '../../lib/mp3_server/http_response_headers_util'

class IndexController < BaseController
  def show(req)
    html_res = HttpResponseHeadersUtil.get_html_response_headers 'public/index.html' 
    [200] + html_res
  end
end
