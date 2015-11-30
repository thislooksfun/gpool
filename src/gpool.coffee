fs = require "fs"
pathMod = require "path"

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

printUsage =
  all: ->
    Main.print "usage: gpl -r [repo] [commands]"
    Main.print "       gpl -a [commands]"
  
  forRepo: -> Main.print "usage: gpl -r [repo] [commands]"
  forAll: -> Main.print "usage: gpl -a [commands]"


forAll = (args) ->
  unless args.length > 3
    printUsage.forAll()
    return false
  
  argList = (arg for arg, i in args when i > 2)
  Main.print "running"
  Main.print "   - git #{argList.join ' '}"
  Main.print "for all repositories"
  
  return true


forRepo = (args) ->
  unless args.length > 4
    printUsage.forRepo()
    return false
  
  argList = (arg for arg, i in args when i > 3)
  Main.print "running"
  Main.print "   - git #{argList.join ' '}"
  Main.print "for repository '#{args[3]}'"
  
  return true


module.exports = Main =
  write: process.stdout.write
  print: console.log
  
  return: (args) ->
    process.title = "gpool"
    
    throw new Error("'args' variable improperly set to: #{args}") unless Array.isArray args
    
    manifest = parseManifest()
    
    unless manifest?
      printDirNotValid()
      return 1
    
    unless args.length > 2
      printUsage.all()
      return 1
    
    switch args[2]
      when "-a" then return 1 unless forAll args, manifest
      when "-r" then return 1 unless forRepo args, manifest
      else
        printUsage.all()
        return -1
    
    return 0