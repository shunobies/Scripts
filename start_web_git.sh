#!/bin/bash
my_path="/var/www/timcomp"
cd $my_path
git init
git branch -m master
git add .
sleep 3
git commit -m "Initial Commit"
git remote add origin \
ssh://WebServer/var/www/timcomp
git push --set-upstream origin master -f
