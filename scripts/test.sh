EXIT_STATUS=0
mocha --compilers coffee:coffee-script/register || EXIT_STATUS=$?
echo "\nlinting 'src' directory:\n"
coffeelint -f ./coffeelint.json src || EXIT_STATUS=$?
echo "\nlinting 'test' directory:\n"
coffeelint -f ./coffeelint.json test || EXIT_STATUS=$?
exit $EXIT_STATUS