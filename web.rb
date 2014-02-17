require 'sinatra'
require './chatwork'
require 'json'

post '/hook/:token/:room_id' do

  cw = Chatwork.new(token: params[:token], room_id: params[:room_id])

  begin

    return 'ng' if params[:token].nil? || params[:room_id].nil? || params[:payload].nil?

    payload = JSON.parse(params[:payload])
    cw.post %Q|[info][title]Githubにpushされました[/title]
    Committer: #{payload['head_commit']['committer']['username']}
    Commits: #{payload['commits'].count}
    Compare: #{payload['compare']}
    Message: #{payload['head_commit']['message']}
    [/info]
    |

    'ok'

  rescue => err
    payload = JSON.parse(params[:payload])
    cw.post %Q|[info][title]github hook error[/title]
    Message: #{err}
    [/info]
    |

    'ng'
  end
end
