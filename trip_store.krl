ruleset trip_store {
  meta {
    name "Trip Store"
    description <<
A ruleset for the lab
>>
    author "Daniel Lee"
    logging on
    shares collect_trips, collect_long_trips, clear_trips, __testing, trips, long_trips, short_trips
    provides trips, long_trips, short_trips
  }

  global {
    __testing = { "queries": [ { "name": "__testing" }, { "name": "trips" }, { "name": "long_trips" }, { "name": "short_trips" } ],
              "events": [ { "domain": "explicit", "type": "trip_processed", "attrs": ["mileage"]},
                          { "domain": "explicit", "type": "found_long_trip", "attrs": ["mileage"]},
                          { "domain": "car", "type": "trip_reset" }]
            }
    trips = function() {
      ent:trips
    }
    long_trips = function() {
      ent:long_trips
    }
    short_trips = function() {
      ent:trips.filter(function(x){ x{"mileage"} < 200 })
    }
  }

  rule collect_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("mileage").as("Number")
      timestamp = time:now()
    }
    always {
      ent:trips := ent:trips.append({"mileage": mileage, "timestamp": timestamp})
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre{
      mileage = event:attr("mileage").as("Number")
      timestamp = time:now()
    }
    send_directive("store") with
      trip_mileage = mileage
      trip_timestamp = timestamp
    always {
      ent:long_trips := ent:long_trips.append({"mileage": mileage, "timestamp": timestamp})
    }
  }

  rule clear_trips {
    select when car trip_reset
    pre{
      newTrips = []
      newLongTrips = []
    }
    send_directive("reset_arrays") with
      trips = newTrips
      long_trips = newLongTrips
    always {
      ent:trips := newTrips;
      ent:long_trips := newLongTrips
    }
  }
}
