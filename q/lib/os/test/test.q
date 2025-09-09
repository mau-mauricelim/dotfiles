system"d .test" / before
n:3; tmp:`:tmp / before
notAnyExist:{not any .util.exists each x} / before
allExist:{all .util.exists each x} / before
.os.name<>`unknown / true
.os.type in`l`m`s`v`w / true
.os.arch in`x86`x86_64 / true

pwd:.os.pwd` / run
n sublist .os.env` / run
n sublist .os.ver` / run
n sublist .os.nproc` / run
pwd~.os.cd` / true
// NOTE: Creates the directory if it does not exist
.os.cd tmp / run

joinStr:" "sv / run
splitStrDirs:.util.strPath each("dir1";"dir2";"\"dir3 with space\"";"dir4/nested";"\"dir5 nested/deeper/with space\"") / run
joinedStrDirs:joinStr splitStrDirs / run
.os.mkdir joinedStrDirs / run
.os.ls` / run
splitStrDirsNoQuote:splitStrDirs except\:"\"" / run
symDirs:.q.Hsym splitStrDirsNoQuote / run
allExist symDirs / true
quoteIfSpace:{$[" "in x;"\"",x,"\"";x]} / run
indvJoinedStrDirs:joinStr quoteIfSpace each raze[.util.dirname\'[splitStrDirsNoQuote]]except enlist"" / run
.os.ls indvJoinedStrDirs / run
.os.rmdir indvJoinedStrDirs / run
notAnyExist symDirs / true

.os.mkdir joinedStrDirs / run
rootJoinedStrDirs:joinStr{quoteIfSpace first"/"vs x}each splitStrDirsNoQuote / run
.os.rmrf rootJoinedStrDirs / run
notAnyExist symDirs / true

.os.mkdir joinedStrDirs / run
destDir:"dir6" / run
.os.mkdir destDir / run
.os.cpr rootJoinedStrDirs:joinStr(rootJoinedStrDirs;destDir) / run
.os.cd destDir / run
allExist symDirs / true
.os.cd".." / run
.os.rmrf rootJoinedStrDirs / run

`rm`mv`cp`ln`tail`touch`which`pg`sigint`sigterm`sigkill`sleep
file1:"file1" / run
file2:"\"file2 with space\"" / run
.os.touch file1 / run
.os.cp joinStr files:(file1;file2) / run
.os.rm file1 / run
.os.mv joinStr reverse files / run
