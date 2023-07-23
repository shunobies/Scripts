#!/bin/bash
start="\$PATH"
echo "Example: "
echo $PATH | awk 'BEGIN{RS=":"}{print $0}'
read -p 'Please enter path to be invluded in $PATH: ' uservar

export PATH="$HOME/bin:$PATH"
echo export PATH=\"${uservar}:${start}\" >> ~/.bashrc
source ~/.bashrc
echo $PATH | awk 'BEGIN{RS=":"}{print $0}'