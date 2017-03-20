ruleset trips {
  meta {
    name "Trips"
    description <<
A ruleset for the lab
>>
    author "Daniel Lee"
    logging on
    shares process_trip, __testing
  }

  global {
    long_trip = 200
    __testing = { "queries": [ { "name": "__testing" } ],
              "events": [ { "domain": "car", "type": "new_trip", "attrs": ["mileage"]},
                          { "domain": "explicit", "type": "trip_processed", "attrs": ["mileage"]}]
            }
  }

  rule process_trip {
    select when car new_trip
    send_directive("trip") with
      trip_length = event:attr("mileage")
    fired {
      raise explicit event "trip_processed"
        attributes {"mileage": event:attr("mileage"), "timestamp": time:now()}
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      check = event:attr("mileage").as("Number") > long_trip.as("Number")
    }
    if (check) then
      noop()
    fired {
      raise explicit event "found_long_trip"
        attributes event:attrs()
    }
  }
}
