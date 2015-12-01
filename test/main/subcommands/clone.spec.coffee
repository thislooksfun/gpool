fs = require "fs"
path = require "path"
mkdirp = require "mkdirp"
rmdir = require "rmdir"

describe "The clone command", ->
  gpl = null
  logSpy = null
  tmpDir = path.join(process.cwd(), "test/tmp")
  
  before (done) ->
    gpl = require "../../../src/gpool"
    mkdirp tmpDir, (err) ->
      throw err if err
      done()
  
  after (done) ->
    rmdir tmpDir, (err) ->
      throw err if err
      done()
  
  
  beforeEach ->
    # Replace with empty function to keep from printing to the console
    logSpy = simple.mock gpl, "print", (msg) -> console.log msg
    simple.mock process, "cwd", -> return tmpDir
  
  afterEach ->
    simple.restore()
  
  
  
  it "should clone into the current directory", ->
    @timeout 20000
    @slow 10000
    
    title = process.title
    expect(gpl.run(["", "", "clone", "git@github.com:vidr-group/vidr-manifest"])).to.eql 0
    process.title = title
  
  it.skip "should clone into the given directory", ->
    @timeout 20000
    @slow 10000
    
    title = process.title
    expect(gpl.run(["", "", "clone", "git@github.com:vidr-group/vidr-manifest", "stuff"])).to.eql 0
    process.title = title