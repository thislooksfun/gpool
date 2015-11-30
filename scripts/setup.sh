#!/bin/bash

git clone https://github.com/vidr-group/code-guide.git ./code-guide
cp ./code-guide/coffeelint.json ./coffeelint.json
rm -rf ./code-guide

chmod +x ./scripts/test.sh