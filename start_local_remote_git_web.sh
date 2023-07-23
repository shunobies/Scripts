#!/bin/sh
read -p "Site Name: " site
git init
git branch -m master
git add .
sleep 1
git commit -m "Initial Commit"
sleep 1
echo "Adding Remote"
git remote add origin \
read -p "Remote Repo Path: " repo
ssh://WebServer/${repo}/$site.git
git push --set-upstream origin master
git push
echo "First Commit Completed and Your all Set"
