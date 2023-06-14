@REM This script is for updating any changes to the git repo
@echo off
set branchName = "sani"
echo %branchName%
echo "Before running this script make sure that you have a branch named %branchName% and have all your changes commited only in that branch."
git checkout master
git merge %branchName%
git push -u origin master

@REM For any kind of conflict in merging you need to manage it manually.