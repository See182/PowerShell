@ECHO OFF
REM Change Code so that ÖÄÜ is supported
CHCP 1252

REM Change Directory
cd C:\Users

REM Read each line from just created text file...
for /f "tokens=*" %%G in (C:\CleanerScript\Clean.txt) do (

REM Delete the Folders
RMDIR /s /q %%G

)

REM Delete Text Files
DEL C:\CleanerScript\Clean.txt