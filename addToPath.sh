#!/bin/bash
echo "Example: "
echo $PATH | awk 'BEGIN{RS=":"}{print $0}'
read -p 'Please enter path to be invluded in $PATH: ' uservar

echo "${uservar}:$PATH" >> ~/.bashrc
source ~/.bashrc
echo $PATH | awk 'BEGIN{RS=":"}{print $0}'

