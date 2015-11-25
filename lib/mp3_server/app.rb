require 'json'
require_relative 'http_response_headers_util'
require_relative 'video_processing_error'
require_relative 'uri_receiver'

class Mp3ServerApp
  private
  # Runs youtube-dl and avconv to convert video to audio and returns file
  # Raises: VideoProcessingError
  def process_video(uri, video_id)
    # TODO: consider if %(ext)s is not .mp4 or .mp3
    system 'youtube-dl', '-o', "public/mp3/#{video_id}.%(ext)s", uri.to_s

    unless File.file? "public/mp3/#{video_id}.mp3"
      system 'avconv', '-i', "public/mp3/#{video_id}.mp4", '-vn', '-f', 'mp3', "public/mp3/#{video_id}.mp3"
      system *%W[rm public/mp3/#{video_id}.mp4]
    end

    if $?.exitstatus != 0 then raise VideoProcessingError; end

    File.open "public/mp3/#{video_id}.mp3", File::RDONLY
  end

  def create_video_id_from_uri(uri)
    host = uri.host
    video_id = ''

    slugify = lambda do |s|
      s.downcase.gsub(/[\s.\/_]/, ' ').squeeze(' ').gsub(/[^\w-]/, '').strip.tr(' ', '-');
    end

    if host.match /soundcloud.com/
      video_id = slugify.call uri.path
    elsif host.match /youtube.com/
      video_id = slugify.call(URI::decode_www_form(uri.query).to_h['v'])
    end
  end

  def get_mp3_file(uri)
    video_id = create_video_id_from_uri uri
    path = "public/mp3/#{video_id}.mp3"

    # check if file exists in cache
    File.exists?(path) ? File.open(path, File::RDONLY) : process_video(uri, video_id)
  end

  # returns an mp3 if all goes well.
  # returns { 'Content-Type' => json } with error message otherwise
  def append_mp3_to_response(uri)
    begin
      mp3 = get_mp3_file uri
      video_id = create_video_id_from_uri uri
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

    res += req.path.split('/')[1] == 'dl' ? append_mp3_to_response(UriReceiver.new.get_uri(req.params)) : append_index_to_response
  end
end
