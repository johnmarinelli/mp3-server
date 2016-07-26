require_relative './base_controller'
require_relative '../../lib/mp3_server/http_response_headers_util'
require_relative '../../lib/mp3_server/video_processing_error'
require_relative '../../lib/mp3_server/uri_receiver'

class VideoFileController < BaseController
  public

  def process_video(uri, video_id)
    cmd = "youtube-dl -f bestvideo[ext=mp4]+bestaudio[ext=m4a] -o public/mp4/#{video_id} #{uri.to_s}"
    system cmd

    if $?.exitstatus != 0 then raise VideoProcessingError; end

    File.open "public/mp4/#{video_id}.mp4", File::RDONLY
  end


  def create_video_id_from_uri(uri)
    host = uri.host
    video_id = ''

    slugify = lambda do |s|
      s.downcase.gsub(/[\s.\/_]/, ' ').squeeze(' ').gsub(/[^\w-]/, '').strip.tr(' ', '-');
    end

    slugify.call(URI::decode_www_form(uri.query).to_h['v'])
  end

  def get_video_file(uri)
    video_id = create_video_id_from_uri uri
    path = "public/mp4/#{video_id}.mp3"
    
    process_video uri, video_id
  end

  def get_video_response(uri)
    begin
      video = get_video_file uri
      video_id = create_video_id_from_uri uri
      HttpResponseHeadersUtil.get_mp4_response_headers video_id, video
    rescue IOError => e
      HttpResponseHeadersUtil.get_json_response_headers({ :error => e }.to_json)
    end
  end

  def get_file(req)
    uri = UriReceiver.new.get_uri req.params
    video_res = get_video_response uri
    [200] + video_res
  end
end
