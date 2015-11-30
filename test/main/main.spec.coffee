fs = require "fs"
path = require "path"
mkdirp = require "mkdirp"


describe "The command", ->
  gpl = null
  logSpy = null
  tmpDir = path.join(process.cwd(), "test/tmp")
  
  before ->
    gpl = require "../../src/gpool"
  
  beforeEach ->
    # Replace with empty function to keep from printing to the console
    logSpy = simple.mock gpl, "print", ->
    
    simple.mock process, "cwd", -> return tmpDir
  
  afterEach ->
    simple.restore()
  
  
  
  describe "should print an error message and exit when given an invalid directory", ->
    it "with no .gpl folder", ->
      title = process.title
      expect(gpl.run([])).to.eql 1
      process.title = title
      
      expect(logSpy.called).to.be.true
      expect(logSpy.calls.length).to.eql 1
      expect(logSpy.calls[0].args).to.eql ["Error: not a valid gpool directory -
        '.gpl/gpl_manifest.json' not found in this or any parent directory"]
    
    
    it "with a .gpl folder, but no gpl_manifest.json", (done) ->
      mkdirp path.join(tmpDir, ".gpl/"), (err) ->
        throw err if err
        
        title = process.title
        expect(gpl.run([])).to.eql 1
        process.title = title
        
        expect(logSpy.called).to.be.true
        expect(logSpy.calls.length).to.eql 2
        manifestMatch = /ENOENT: no such file or directory, open '.+\.gpl\/gpl_manifest\.json'/
        expect(logSpy.calls[0].args).to.match manifestMatch
        expect(logSpy.calls[1].args).to.eql ["Error: not a valid gpool directory -
          '.gpl/gpl_manifest.json' not found in this or any parent directory"]
        done()
  
  
  
  describe "when run in a valid directory", ->
    
    before "Create files needed for a valid directory", (done) ->
      testData =
        remotes:
          github:
            type: "ssh"
            user: "git"
            url: "github.com"
            git_name: "origin"
        repositories:
          core:
            remote: "github"
            user: "vidr-group"
            repo: "vidr-manifest"
      
      mkdirp path.join(tmpDir, ".gpl/"), (err) ->
        throw err if err
        
        mnfstPath = path.join(tmpDir, ".gpl/gpl_manifest.json")
        json = JSON.stringify(testData, null, 2)
        fs.writeFile mnfstPath, json, (err) ->
          throw err if err
          done()
    
    after "Clean up tmp folder", (done) ->
      rmdir = require "rmdir"
      
      rmdir tmpDir, (err) ->
        throw err if err
        done()
    
    it "should print usage and exit when no options given specified", ->
      title = process.title
      expect(gpl.run([])).to.eql 1
      process.title = title
      
      expect(logSpy.called).to.be.true
      expect(logSpy.calls.length).to.eql 2
      expect(logSpy.calls[0].args).to.eql ["usage: gpl -r [repo] [commands]"]
      expect(logSpy.calls[1].args).to.eql ["       gpl -a [commands]"]
    
    
    
    describe "with a specific repository", ->
      it "should print usage and exit when given invalid arguments", ->
        title = process.title
        expect(gpl.run(["", "", "-r", "repo"])).to.eql 1
        process.title = title
        
        expect(logSpy.called).to.be.true
        expect(logSpy.calls.length).to.eql 1
        expect(logSpy.calls[0].args).to.eql ["usage: gpl -r [repo] [commands]"]
      
      it "should succeed when given valid arguments", ->
        title = process.title
        expect(gpl.run(["", "", "-r", "repo", "command"])).to.eql 0
        process.title = title
    
    
    
    describe "for all repositories", ->
      it "should print usage and exit when given invalid arguments", ->
        title = process.title
        expect(gpl.run(["", "", "-a"])).to.eql 1
        process.title = title
        
        expect(logSpy.called).to.be.true
        expect(logSpy.calls.length).to.eql 1
        expect(logSpy.calls[0].args).to.eql ["usage: gpl -a [commands]"]
      
      
      it "should succeed when given valid arguments", ->
        title = process.title
        expect(gpl.run(["", "", "-a", "command"])).to.eql 0
        process.title = title
    
    
    
    describe "when run in a subdirectory", ->
      oldTmpDir = ""
      
      before "Create subdirectory", (done) ->
        oldTmpDir = tmpDir
        tmpDir = path.join(tmpDir, "src/main/code")
        
        mkdirp tmpDir, (err) ->
          throw err if err
          done()
      
      after ->
        tmpDir = oldTmpDir
      
      
      it "should find the .gpl folder in a parent directory", ->
        title = process.title
        expect(gpl.run(["", "", "-a", "command"])).to.eql 0
        process.title = title