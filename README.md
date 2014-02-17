github-web-hook
===============

Notify github webhook to chatwork via API

## Events type

- issue_comment
- commit_comment
- pull_request
- pull_request_review_comment

see also: https://developer.github.com/webhooks/

## How to use

1. Clone this codes.
2. Create heroku app and deploy.
2. Set github webhook payload url in repo's settings page.
  - like: http://your-app-name.herokuapp.com/hook/chatwork-api-token/chat-room-id
3. Have fan!
