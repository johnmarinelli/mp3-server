use Rack::Static,
  :urls => ['/mp3'],
  :root => 'public'

class Mp3ServerApp
  private
  def get_mp3_file_response_headers(filename)
    {
      'Content-Type' => 'audio/mpeg',
      'Content-Disposition' => "attachment; filename=\"#{filename}\""
    }
  end

  def get_mp3_file(filename)
    File.open "public/mp3/#{filename}", File::RDONLY
  end

  def append_mp3_to_response(filename)
    [get_mp3_file_response_headers(filename), get_mp3_file(filename)]
  end

  public

  def call(env)
    req = Rack::Request.new env
    res = [200]

    res += append_mp3_to_response(req.params['f']) if req.post?
  end
end
  
run Mp3ServerApp.new
