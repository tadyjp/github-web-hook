require 'faraday'

class Chatwork

  def initialize(opts)
    @token = opts[:token]
    @room_id = opts[:room_id]
  end

  # ChatworkにPOST
  def post(text)
    conn = Faraday::Connection.new(url: 'https://api.chatwork.com') do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Adapter::NetHttp
    end
    response = conn.post do |request|
      request.url "/v1/rooms/#{@room_id}/messages"
      request.headers = {
        'X-ChatWorkToken' => @token
      }
      request.params[:body] = text
    end
  end
end
