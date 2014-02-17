require 'sinatra'
require './chatwork'
require 'json'

def compose_message(title, body)
  "[info][title]#{title}[/title]#{body}[/info]"
end

post '/hook/:token/:room_id' do

  begin

    body = JSON.parse(request.body.read)
    cw = Chatwork.new(token: params[:token], room_id: params[:room_id])

    if params[:token].nil? || params[:room_id].nil? || params[:payload].nil?
      cw.post compose_message('Error', 'Request error')
      return 'ng'
    end

    case request['X-Github-Event']
    when 'pull_request'
      cw.post compose_message("PullRequest '#{body['pull_request']['title']}' #{body['action']} by #{body['pull_request']['user']['login']}", <<-EOS)
BODY: #{body['pull_request']['body']}
--
URL: #{body['pull_request']['url']}
      EOS
    when 'pull_request_review_comment'
      cw.post compose_message("PullRequestComment by #{body['comment']['user']['login']}", <<-EOS)
BODY: #{body['comment']['body']}
--
URL: #{body['comment']['url']}
      EOS
    end

  rescue => err
    cw.post %Q|[info][title]github hook error[/title]
    Message: #{err}
    [/info]
    |

    'ng'
  end
end
