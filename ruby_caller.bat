echo off
echo %1 %2 %3 %4 
archiver --xcalibur %1 %2 >> C:/testing.txt
echo %1 %2 %3 %4 >> C:/testing.txt
echo on
