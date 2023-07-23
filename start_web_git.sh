#!/bin/bash
echo "Assumes you have a ~/.ssh/config for your server"
read -p "Local Path to Site Files: " my_path
cd $my_path
git init
git branch -m master
git add .
sleep 3
git commit -m "Initial Commit"
git remote add origin \
read -p "Server Path to Site Files: " server_path
ssh://WebServer/${server_path}
git push --set-upstream origin master -f