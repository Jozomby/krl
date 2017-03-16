ruleset track_trips {
  meta {
    name "Track Trips"
    description <<
A ruleset for the lab
>>
    author "Daniel Lee"
    logging on
    shares process_trip, __testing
  }

  global {
    __testing = { "queries": [ { "name": "__testing" } ],
              "events": [ { "domain": "echo", "type": "message", "attrs": ["mileage"]}]
            }
  }

  rule process_trip {
    select when echo message
    send_directive("trip") with
      trip_length = event:attr("mileage")
  }
}
