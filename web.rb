require 'sinatra'
require './chatwork'
require 'json'

post '/hook/:token/:room_id' do

  p params

  return 'ng' if params[:token].nil? || params[:room_id].nil?

  cw = Chatwork.new(token: params[:token], room_id: params[:room_id])
  payload = JSON.parse(params[:payload])
  cw.post %Q|[info]
  [title]Githubにpushされました[/title]
  User: #{payload['pusher']['name']}
  Commit: #{payload['commits'].count}
  compare: #{payload['compare']}
  [/info]
  |

  'ok'
end
