:: Define programs to install
set PACKAGES= ^
    googlechrome ^
    firefox ^
    enpass.install ^
    adobereader ^
    ^
    7zip.install ^
    filezilla ^
    windirstat ^
    autohotkey.portable ^
    ^
    notepadplusplus ^
    hexedit ^
    meld ^
    atom ^
    boostnote ^
    ^
    virtualbox

:: Install all the packages
for %%G in (%PACKAGES%) do choco install %%G -fy
