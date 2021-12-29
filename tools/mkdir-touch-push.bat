@echo off
set /p UserInputPath=What Directory would you like?
mkdir %UserInputPath%
cd %UserInputPath%
touch README.md
nano README.md
echo "Set it in README.md:"
echo   - [%UserInputPath%](../master/%UserInputPath%/README.md)
sleep 5
set /p Pushtime=Would you like to push changes FIRST Save base README and then Press ENTER:
cd ../
git add .
git commit -m "%UserInputPath%"
git push
cls
call rake
echo done
exit
