# receives a JSON-encoded URI object from client.  
# unpacks it and returns a sanitized URI for youtube-dl to process

class UriReceiver
private
  # makes assumptions about the given uri and manipulates accordingly
  # { :host, :path, :query }
  def clean_uri(uri)
    clean_uri = uri
    # remove backslashes from uri
    clean_uri[:host].delete! '/'

    # make sure path is absolute
    path = clean_uri[:path]
    clean_uri[:path] = path.prepend('/') unless (path.nil? or path[0] == '/')

    clean_uri
  end

public

  def get_uri_from_params(host, path, query)
    {
      :host => host,
      :path => path,
      :query => query
    }
  end

  # expect { :host, :path, :query }.to_json
  def get_uri(params)
    # symbolizes keys and decodes values
    decoded_params = Hash[params.map { |k,v| [k.to_sym, URI.decode_www_form_component(v)] }]
    uri = get_uri_from_params decoded_params[:host], decoded_params[:path], decoded_params[:query]
    # clean up uri
    clean_uri = clean_uri uri
    URI::HTTP.build clean_uri
  end
end
