require 'sinatra/base'
require './chatwork'
require 'json'
require 'hipchat'

# github => hipchat
NICKNAME_HASH = {
  'tadyjp' => 'tady',
  'sudoz' => 'sudo',
  'ytumura' => 'ted',
  'kanouchi-z' => 'UT3'
}

# chatworkメッセージ
def compose_message(title, body)
  "[info][title]#{title}[/title]#{body}[/info]"
end

# hipchatメッセージ
def compose_hipchat_message(_body)
  NICKNAME_HASH.each do |_from, _to|
    _body.gsub!(/@#{_from}/, "@#{_to}")
  end

  _body
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

        # `opened`以外はOFF
        if body['action'] != 'opened'
          return "ok - pull_request: #{body['action']}"
        end

        cw.post compose_message("PullRequest '#{body['pull_request']['title']}' #{body['action']} by #{body['pull_request']['user']['login']}", <<-EOS)
BODY:
#{body['pull_request']['body']}
--
URL:
#{body['pull_request']['html_url']}
        EOS

        return "ok - pull_request: #{body['action']}"

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








  post '/hipchat/:token/:room' do

    begin

      client = HipChat::Client.new(params[:token])
      body = JSON.parse request.body.read

      if params[:token].nil? || params[:room].nil?
        client[params[:room]].send('github', compose_hipchat_message('Error: Auth error'), :message_format => 'text')
        return 'ng'
      end

      case request.env['HTTP_X_GITHUB_EVENT']
      when 'pull_request'

        # `opened`以外はOFF
        if body['action'] != 'opened'
          return "ok - pull_request: #{body['action']}"
        end

        client[params[:room]].send('github', compose_hipchat_message(<<-EOS), :message_format => 'text')
PullRequest '#{body['pull_request']['title']}' #{body['action']} by #{body['pull_request']['user']['login']}

BODY:
#{body['pull_request']['body']}
--
URL:
#{body['pull_request']['html_url']}
        EOS

        return "ok - pull_request: #{body['action']}"

      when 'issue_comment'
        client[params[:room]].send('github', compose_hipchat_message(<<-EOS), :message_format => 'text')
IssueCommented #{body['action']} by #{body['comment']['user']['login']}

BODY:
#{body['comment']['body']}
--
URL:
#{body['comment']['html_url']}
        EOS

        return 'ok - issue_comment'

      when 'commit_comment'
        client[params[:room]].send('github', compose_hipchat_message(<<-EOS), :message_format => 'text')
CommitCommented #{body['action']} by #{body['comment']['user']['login']}

BODY:
#{body['comment']['body']}
--
URL:
#{body['comment']['html_url']}
        EOS

        return 'ok - issue_comment'

      when 'pull_request_review_comment'
        client[params[:room]].send('github', compose_hipchat_message(<<-EOS), :message_format => 'text')
PullRequestComment by #{body['comment']['user']['login']}

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
      client[params[:room]].send('github', compose_hipchat_message("github hook error: #{err}"), :message_format => 'text')
      'ng'
    end
  end
end
