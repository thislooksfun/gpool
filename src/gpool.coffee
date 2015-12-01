fs = require "fs"
pathMod = require "path"
rmdir = require "rmdir"

# Add shelljs functions
require "shelljs/global"


#################
# Helper things #
#################

String::startsWith ?= (s) -> @slice(0, s.length) is s
String::endsWith   ?= (s) -> s is '' or @slice(-s.length) is s

runCmd = (cmd) ->
  Main.print "Running command '#{cmd}' at path #{pwd()}" if Main.options.verbose
  
  return exec cmd, {silent: true}

rmdirSync = (path) ->
  done = false
  rmdir path, (err) ->
    throw err if err
    done = true
  
  # Wait
  require('deasync').loopWhile -> return not done


#############
# Main code #
#############

printHelp = ->
  Main.print "Help messages!"

hasDotGpl = (path) ->
  try
    stat = fs.statSync pathMod.join(path, ".gpl")
    return stat.isDirectory()
  catch err
    return false

findAndParseManifest = ->
  try
    # TODO: Search parents
    path = root = process.cwd()
    
    until hasDotGpl(path)
      return null if path is "/"
      path = pathMod.join(path, "..")
    
    return parseManifest pathMod.join(path, ".gpl/gpl_manifest.json")
  catch err
    Main.print err.message
  
  # Errored or didn't find anything
  return null

parseManifest = (path) ->
  raw = fs.readFileSync path
  return JSON.parse raw

printDirNotValid = ->
  Main.print "Error: not a valid gpool directory -
    '.gpl/gpl_manifest.json' not found in this or any parent directory"


doClone = (args) ->
  argList = (arg for arg, i in args when i > 2)
  
  unless argList.length > 0 and argList.length < 3
    Main.usage.clone.print()
    return false
  
  dir = process.cwd()
  
  rmdirSync "/tmp/manifest"
  
  res = runCmd "git clone #{argList[0]} /tmp/manifest"
  unless res.code is 0
    Main.print res.output
    return false
  
  return false unless (fs.statSync "/tmp/manifest/gpl_manifest.json").isFile()
  manifest = parseManifest "/tmp/manifest/gpl_manifest.json"
  
  path = ""
  if argList.length is 1
    # Clone here
    path = dir
  else if argList.length is 2
    # Clone elsewhere
    path = pathMod.resolve dir, argList[1]
  
  errors = []
  for repo in manifest.repositories
    remote = manifest.remotes[repo.remote]
    unless remote?
      errors.push {name: repo.repo, value: "Couldn't find a remote for #{repo.repo}"}
    
    url = ""
    if remote.type is 'https'
      url = remote.url
      url = "#{url}/" unless url.endsWith "/"
    else if remote.type is 'ssh'
      url = "#{remote.user}@#{remote.url}"
      url = "#{url}:" unless url.endsWith ":"
    
    url = "#{url}#{repo.user}/#{repo.repo}"
    rPath = pathMod.resolve path, repo.path
    
    cmd = "git clone #{url} #{rPath}"
    res = runCmd cmd
    unless res.code is 0
      errors.push {name: repo.repo, value: res.output}
      return false
  
  if errors.length isnt 0
    for err in errors
      Main.print ""
  
  mkdir "#{path}/.git"
  cp "/tmp/manifest/gpl_manifest.json", "#{path}/.git/gpl_manifest.json"
  
  return true

forAll = (args, manifest) ->
  unless args.length > 3
    Main.usage.forAll.print()
    return false
  
  argList = (arg for arg, i in args when i > 2)
  Main.print "running"
  Main.print "   - git #{argList.join ' '}"
  Main.print "for all repositories"
  
  # TODO: return false at end
  return true


forRepo = (args, manifest) ->
  unless args.length > 4
    Main.usage.forRepo.print()
    return false
  
  argList = (arg for arg, i in args when i > 3)
  Main.print "running"
  Main.print "   - git #{argList.join ' '}"
  Main.print "for repository '#{args[3]}'"
  
  # TODO: return false at end
  return true


runCommand = (args) ->
  switch args[2]
    when "help" then return printHelp args
    when "clone" then return doClone args
    else #do nothing
  
  manifest = findAndParseManifest()
  unless manifest?
    printDirNotValid()
    return false
  
  switch args[2]
    when "-a" then return forAll args, manifest
    when "-r" then return forRepo args, manifest
    else
      Main.usage.printAll()
      return false
    

module.exports = Main =
  write: process.stdout.write
  print: console.log
    
  
  run: (args) ->
    process.title = "gpool"
    
    throw new Error("'args' variable improperly set to: #{args}") unless Array.isArray args
    
    unless args.length > 2
      @usage.printAll()
      return 1
    
    return (if runCommand(args) then 0 else 1)
  
  
  options:
    verbose: false  # TODO set flags
  
  usage:
    printAll: ->
      first = true
      for k,v of @ when k isnt "printAll"
        Main.print "#{(if first then "usage: " else "       ")} #{v.get()}"
        first = false
    
    clone:
      get: -> return "gpl clone [remote]"
      print: -> Main.print "usage: #{@get()}"
    
    forRepo:
      get: -> return "gpl -r [repo] [commands]"
      print: -> Main.print "usage: #{@get()}"
      
    forAll:
      get: -> return "gpl -a [commands]"
      print: -> Main.print "usage: #{@get()}"