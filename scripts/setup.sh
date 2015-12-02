#!/bin/bash

git clone --depth 1 https://github.com/vidr-group/code-guide.git ./code-guide
cp ./code-guide/coffeelint.json ./coffeelint.json
rm -rf ./code-guide

chmod +x ./scripts/test.sh