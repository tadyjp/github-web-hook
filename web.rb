require 'sinatra/base'
require './chatwork'
require 'json'

def compose_message(title, body)
  "[info][title]#{title}[/title]#{body}[/info]"
end

class GithubWebHook < Sinatra::Base

  post '/hook/:token/:room_id' do

    body = JSON.parse request.body

    begin

      cw = Chatwork.new(token: params[:token], room_id: params[:room_id])
      cw.post compose_message('test', 'text')

      if params[:token].nil? || params[:room_id].nil?
        cw.post compose_message('Error', 'Auth error')
        return 'ng'
      end

      case request.env['HTTP_X_GITHUB_EVENT']
      when 'pull_request'
        cw.post compose_message("PullRequest '#{body['pull_request']['title']}' #{body['action']} by #{body['pull_request']['user']['login']}", <<-EOS)
  BODY: #{body['pull_request']['body']}
  --
  URL: #{body['pull_request']['url']}
        EOS

        return 'ok - pull_request'
      when 'pull_request_review_comment'
        cw.post compose_message("PullRequestComment by #{body['comment']['user']['login']}", <<-EOS)
  BODY: #{body['comment']['body']}
  --
  URL: #{body['comment']['url']}
        EOS

        return 'ok - pull_request_review_comment'

      else

        return 'else'
      end

    rescue => err
      cw.post %Q|[info][title]github hook error[/title]
      Message: #{err}
      [/info]
      |

      'ng'
    end
  end
end
