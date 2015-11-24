require 'json'
require_relative 'http_response_headers_util'
require_relative 'video_processing_error'

class Mp3ServerApp
  private
  # Runs youtube-dl and avconv to convert video to audio and returns file
  # Raises: VideoProcessingError
  def process_video(url, video_id)
    system 'youtube-dl', '-o', 'public/mp3/%(id)s.%(ext)s', url.to_s
    system *%W[avconv -i public/mp3/#{video_id}.mp4 -vn -f mp3 public/mp3/#{video_id}.mp3]
    system *%W[rm public/mp3/#{video_id}.mp4]

    if $?.exitstatus != 0 then raise VideoProcessingError; end

    File.open "public/mp3/#{video_id}.mp3", File::RDONLY
  end

  def create_video_id_from_url(url)
    host = url.host
    video_id = ''
    if host.match /soundcloud.com/
      video_id = url.path
    elsif host.match /youtube.com/
      video_id = url.query
    end
  end

  def get_mp3_file(url)
    video_id = create_video_id_from_url url
    path = "public/mp3/#{video_id}.mp3"

    # check if file exists in cache
    File.exists?(path) ? File.open(path, File::RDONLY) : process_video(video_id)
  end

  # returns an mp3 if all goes well.
  # returns { 'Content-Type' => json } with error message otherwise
  def append_mp3_to_response(url)
    begin
      mp3 = get_mp3_file url
      video_id = create_video_id_from_url url
      HttpResponseHeadersUtil.get_mp3_response_headers video_id, mp3
    rescue IOError => e
      HttpResponseHeadersUtil.get_json_response_headers({ :error => e }.to_json)
    end
  end

  def append_index_to_response
    HttpResponseHeadersUtil.get_html_response_headers 'public/index.html' 
  end

  public

  def call(env)
    req = Rack::Request.new env
    res = [200]

    url = UriReceiver.new.get_uri req.params

    res += req.path.split('/')[1] == 'dl' ? append_mp3_to_response(url) : append_index_to_response
  end
end
