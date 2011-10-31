DIR /B /AD "%1\*.d" >lst
for /F %%a in (lst) do trapper.exe --mzXML -c "%1\%%a" 
for %%a in ("%1\*.mzxml") do mzData2MGF.exe %%a
