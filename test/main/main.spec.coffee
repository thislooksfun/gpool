describe "The command", ->
  
  it "should exit with invalid directory", ->
    gpl = require "../../src/gpool"
    
    logSpy = simple.mock console, "log", -> # Replace with empty function to keep from printing to the console
    gpl.go()
    simple.restore()
    
    expect(logSpy.called).to.be.true
    expect(logSpy.calls.length).to.eql 1
    expect(logSpy.lastCall.args).to.eql ["Error: not a valid gpool directory"]
  
  describe "run in a valid directory", ->
    it.skip "should exit with no options specified", ->
      # Stuff goes here