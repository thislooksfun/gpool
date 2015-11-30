fs = require "fs"
pathMod = require "path"

# Add shelljs functions
require "shelljs/global"


printHelp = ->
  Main.print "Help messages!"

hasDotGpl = (path) ->
  try
    stat = fs.statSync pathMod.join(path, ".gpl")
    return stat.isDirectory()
  catch err
    return false

parseManifest = ->
  try
    # TODO: Search parents
    path = root = process.cwd()
    
    until hasDotGpl(path)
      return null if path is "/"
      path = pathMod.join(path, "..")
    
    raw = fs.readFileSync pathMod.join(path, ".gpl/gpl_manifest.json")
    return JSON.parse(raw)
  catch err
    Main.print err.message
    return null

printDirNotValid = ->
  Main.print "Error: not a valid gpool directory -
    '.gpl/gpl_manifest.json' not found in this or any parent directory"


doClone = (args, manifest) ->
  unless args.length > 1
    Main.usage.clone.print()

forAll = (args) ->
  unless args.length > 3
    Main.usage.forAll.print()
    return false
  
  argList = (arg for arg, i in args when i > 2)
  Main.print "running"
  Main.print "   - git #{argList.join ' '}"
  Main.print "for all repositories"
  
  return true


forRepo = (args) ->
  unless args.length > 4
    Main.usage.forRepo.print()
    return false
  
  argList = (arg for arg, i in args when i > 3)
  Main.print "running"
  Main.print "   - git #{argList.join ' '}"
  Main.print "for repository '#{args[3]}'"
  
  return true


runCommand = (args, manifest) ->
  switch args[2]
    when "help" then return printHelp args
    when "clone" then return doClone args, manifest
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
    
    manifest = parseManifest()
    
    unless manifest?
      printDirNotValid()
      return 1
    
    unless args.length > 2
      @usage.printAll()
      return 1
    
    return (if runCommand(args, manifest) then 0 else 1)
  
  
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