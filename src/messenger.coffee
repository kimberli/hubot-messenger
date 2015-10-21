try
  {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot,Adapter,TextMessage,User} = prequire 'hubot'

login = require('facebook-chat-api')

class MessengerBot extends Adapter

  constructor: (robot) ->
    @robot = robot

  send: (envelope, strings...) ->
    @robot.logger.info "send"
    for str in strings
      # console.log "Sending to #{envelope.room}: #{str}"
      console.log envelope, str

      @client.sendMessage str, envelope.thread

  reply: (envelope, strings...) ->
    @robot.logger.info "reply"
    for str in strings
      console.log envelope, str
      @send envelope, str

  run: ->
    self = @
    config =
      email: process.env.HUBOT_FB_USERNAME
      password: process.env.HUBOT_FB_PASSWORD
    return self.robot.logger.error "No username provided; set HUBOT_FB_USERNAME" unless config.email
    return self.robot.logger.error "No password provided; set HUBOT_FB_PASSWORD" unless config.password
    login {
      email: config.email
      password: config.password,
    }, (err, api) ->
        if err
            self.robot.logger.info 'Error: ' + err
        api.setOptions listenEvents: true
        self.client = api
        api.listen (err, msg) =>
          if err
            self.robot.logger.info 'Error: ' + err
          else if msg.type == 'message'
            self.robot.logger.info "Received raw message (text: #{msg.body})"
            sender = self.robot.brain.userForId msg.threadID,
              name: msg.senderID
              thread: msg.threadID
            self.robot.receive new TextMessage(sender, msg.body)
          return
        return

exports.use = (robot) ->
  new MessengerBot robot
