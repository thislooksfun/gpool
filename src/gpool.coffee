parseManifest = ->
  return false

printDirNotValid = ->
  console.log "Error: not a valid gpool directory"

printUsage =
  all: ->
    console.log "usage: gpl [repo] [commands]"
    console.log "       gpl -a [commands]"
    # process.exit(1)
  
  forRepo: ->
    console.log "usage: gpl [repo] [commands]"
    # process.exit(1)
  forAll:  ->
    console.log "usage: gpl -a [commands]"
    # process.exit(1)


forAll = ->
  return printUsage.forAll() unless process.argv.length > 3
  
  argList = (arg for arg, i in process.argv when i > 2)
  console.log "running"
  console.log "   - git #{argList.join ' '}"
  console.log "for all repositories"


forRepo = ->
  return printUsage.forRepo() unless process.argv.length > 3
  
  argList = (arg for arg, i in process.argv when i > 2)
  console.log "running"
  console.log "   - git #{argList.join ' '}"
  console.log "for repository '#{process.argv[2]}'"


module.exports =
  go: ->
    process.title = "gpool"
    
    unless parseManifest()
      printDirNotValid()
      return 1
    
    unless process.argv.length > 2
      printUsage.all()
      return 1
    
    if process.argv[2] is "-a"
      return 1 unless forAll()
    else
      return 1 unless forRepo()