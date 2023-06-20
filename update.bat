@REM This script is for updating any changes to the git repo
@echo off
@REM Change the below name with your branch name
set branchName=testbranch
echo %branchName%
echo "Before running this script make sure that you have a branch named %branchName% and have all your changes commited only in that branch."
git add .
git commit
git checkout master
git pull origin master
git merge %branchName%
git push -u origin master
git checkout %branchName%

@REM For any kind of conflict in merging you need to manage it manually.