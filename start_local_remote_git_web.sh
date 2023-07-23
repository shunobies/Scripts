#!/bin/sh
echo "Make Sure Git is installed Locally"
sudo dpkg -l | awk '{print$ 2}' | grep --max-count 1 "git"

if [ [ -z "git" ] ]: then
    sudo apt-get install git -y
fi

echo "Assumes you have a ~/.ssh/config for your server"
read -p "Server Name: " serverName
read -p "Site Name no spaces" siteName
read -p "Local Path to Site Files: " localPath
cd ${localPath}
git init
git branch -m master
git add .
sleep 1
git commit -m "Initial Commit"
sleep 1
echo "Adding Remote"
echo "Repo should not be accessible by the web server."
read -p "Remote Repo Git Path: " repoPath
read -p "Remote Apache/Nginx Path: " webPath

if [ ssh ${serverName} '[ -d "'"${repoPath}"'" ] && echo "True" || echo "False"' -eq "False" ]: then
    ssh ${serverName} "mkdir -p ${repoPath}"
    ssh ${serverName} "cd ${repoPath} && git init"
    ssh ${serverName} "cd ${repoPath} && git branch -m origin"
    ssh ${serverName} "cd ${repoPath} && add ."
    ssh ${serverName} 'cd '"${repoPath}"' && git commit -m "Initial Commit"'
    ssh ${serverName} "touch ${repoPath}/hooks/post-receive"
    ssh ${serverName} 'echo "git --work-tree='${webPath}' --git-dir='"${repoPath}"' checkout -f master" >> '"${repoPath}"'/hooks/post-receive'
    ssh ${serverName} 'echo "chown -R www-data:www-data '"${webPath}"'" >> '"${repoPath}"'/hooks/post-receive'
fi

if [ ssh ${serverName} '[ -d "'"${webPath}"'" ] && echo "True" || echo "False"' -eq "False" ]: then
    ssh ${serverName} "mkdir -p ${webPath}"
fi

git remote add origin \
ssh://${serverName}/${repo}/${siteName}.git
git push --set-upstream origin master
git push
echo "First Commit Completed and Your all Set"