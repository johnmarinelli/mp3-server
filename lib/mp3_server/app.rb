require 'json'
require_relative 'http_response_headers_util'
require_relative 'video_processing_error'

class Mp3ServerApp
  private
  # Runs youtube-dl and avconv to convert video to audio and returns file
  # Raises: VideoProcessingError
  def process_video(video_id)
    system 'youtube-dl', '-o', 'public/mp3/%(id)s.%(ext)s', "https://www.youtube.com/watch?v=#{video_id}"
    system *%W[avconv -i public/mp3/#{video_id}.mp4 -vn -f mp3 public/mp3/#{video_id}.mp3]
    system *%W[rm public/mp3/#{video_id}.mp4]

    if $?.exitstatus != 0 then raise VideoProcessingError; end

    File.open "public/mp3/#{video_id}.mp3", File::RDONLY
  end

  def get_mp3_file(video_id)
    path = "public/mp3/#{video_id}.mp3"

    # check if file exists in cache
    File.exists?(path) ? File.open(path, File::RDONLY) : process_video(video_id)
  end

  # returns an mp3 if all goes well.
  # returns { 'Content-Type' => json } with error message otherwise
  def append_mp3_to_response(video_id)
    begin
      HttpResponseHeadersUtil.get_mp3_response_headers video_id, get_mp3_file(video_id)
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

    res += req.path.split('/')[1] == 'dl' ? append_mp3_to_response(req.params['f']) : append_index_to_response
  end
end
