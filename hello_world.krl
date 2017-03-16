ruleset echo {
  meta {
    name "Echo"
    description <<
A first ruleset for the Quickstart
>>
    author "Daniel Lee"
    logging on
    shares hello, __testing
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
    clear_name = { "_0": { "name": { "first": "GlaDOS", "last": "" } } }
    __testing = { "queries": [ { "name": "hello"},
                           { "name": "__testing" } ],
              "events": [ { "domain": "echo", "type": "hello"},
                          { "domain": "echo", "type": "message", "attr": ["input"]}]
            }
  }

  rule hello {
    select when echo hello
    send_directive("say") with
      something = "Hello World"
  }

  rule message {
    select when echo message
    send_directive("say") with
      something = event:attr("input")
  }
}
