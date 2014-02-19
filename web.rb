require 'sinatra/base'
require './chatwork'
require 'json'

def compose_message(title, body)
  "[info][title]#{title}[/title]#{body}[/info]"
end

class GithubWebHook < Sinatra::Base

  post '/hook/:token/:room_id' do

    begin

      cw = Chatwork.new(token: params[:token], room_id: params[:room_id])
      body = JSON.parse request.body.read

      if params[:token].nil? || params[:room_id].nil?
        cw.post compose_message('Error', 'Auth error')
        return 'ng'
      end

      case request.env['HTTP_X_GITHUB_EVENT']
      when 'pull_request'
        cw.post compose_message("PullRequest '#{body['pull_request']['title']}' #{body['action']} by #{body['pull_request']['user']['login']}", <<-EOS)
BODY:
#{body['pull_request']['body']}
--
URL:
#{body['pull_request']['html_url']}
        EOS

        return 'ok - pull_request'

      when 'issue_comment'
        cw.post compose_message("IssueCommented #{body['action']} by #{body['comment']['user']['login']}", <<-EOS)
BODY:
#{body['comment']['body']}
--
URL:
#{body['comment']['html_url']}
        EOS

        return 'ok - issue_comment'

      when 'commit_comment'
        cw.post compose_message("CommitCommented #{body['action']} by #{body['comment']['user']['login']}", <<-EOS)
BODY:
#{body['comment']['body']}
--
URL:
#{body['comment']['html_url']}
        EOS

        return 'ok - issue_comment'

      when 'pull_request_review_comment'
        cw.post compose_message("PullRequestComment by #{body['comment']['user']['login']}", <<-EOS)
BODY:
#{body['comment']['body']}
--
URL:
#{body['comment']['html_url']}
        EOS

        return 'ok - pull_request_review_comment'

      else

        return 'else'
      end

    rescue => err
      cw.post compose_message("github hook error", "Message: #{err}")

      'ng'
    end
  end
end
