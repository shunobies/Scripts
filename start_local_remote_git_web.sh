#!/bin/sh
read -p "Site Name: " site
git init
git branch -m master
git add .
sleep 1
git commit -m "Initial Commit"
sleep 1
echo "Adding Remote"
git remote add prod \
ssh://WebServer/var/repo/$site.git
git push --set-upstream prod master
git push
echo "First Commit Completed and Your all Set"
