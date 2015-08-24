EventSource = require 'eventsource'
http = require 'http'
QS = require 'querystring'
url = require 'url'
data = ""
addr = "https://api.particle.io/v1/events"

module.exports = (robot) ->
  # Declares all header information
  eventSourceInitDict =
    rejectUnauthorized: false
    # You must add your particle authorization token
    headers: 'Authorization': 'Bearer <your authorization code>'
  
  # Opens the channel to the particle cloud  
  es = new EventSource(addr.toString(), eventSourceInitDict)
  
  # See the particle documentation to see how each event is described in JSON
  # Adds a listener for the specific event specified in the <>. 
  es.addEventListener '<some event name>', ((event) ->
    # Puts the event's data into a variable in JSON format
    data = JSON.parse(event.data)
    robot.logger.info "This is the data we got...#{data}"
    robot.logger.info "This is the event type...#{event.type}"
    robot.logger.info "The core ID is -#{data.coreid}- and it's data is -#{data.data}"
    
    # One example use of a particle listener is to log data into a spreadsheet.
    # The following block is code to post info to a google spreadsheet; feel free to remove this, as it is just an example use case.
    robot.http("<google script url>")
      .header('Content-Type', 'application/x-www-form-urlencoded')
      .post("Core_ID=#{data.coreid}&Core_Data=#{data.data}") (err, res, body) ->
        if err
          robot.logger.info "Encountered an error: #{err}"
          return
        else
          robot.logger.info "We got back success!"
    # END CODE BLOCK
    return
  ), false
