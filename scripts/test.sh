EXIT_STATUS=0
mocha --compilers coffee:coffee-script/register || EXIT_STATUS=$?
coffeelint -f ./coffeelint.json src test || EXIT_STATUS=$?
exit $EXIT_STATUS