class HttpResponseHeadersUtil
  def self.get_json_response_headers(msg)
    [
      {
        'Content-Type' => 'application/json',
        'Content-Disposition' => 'attachment; filename=error.json'
      },
      [msg.to_s]
    ]
  end

  def self.get_html_response_headers(filepath)
    [
      {
        'Content-Type' => 'text/html',
        'Cache-Control' => 'public, max-age=86400'
      },
      File.open(filepath, File::RDONLY)
    ]
  end

  def self.get_mp3_response_headers(filename, file)
    [
      {
        'Content-Type' => 'audio/mpeg',
        'Content-Disposition' => "attachment; filename=\"#{filename}\""
      },
      file
    ]
  end
end

