.lib.require`os2
system"d .test"
notAnyExist:{not any .util.exists each x}
allExist:{all .util.exists each x}
cmd: `pwd`env`ver`nproc`cd`ls`mkdir`rmdir`rm`rmrf`mv`cp`cpr`ln`head`tail`cat`touch`which
cmd,:`where`pg`sigint`sigterm`sigkill`sleep
/w:.util.isWin[]
all(k:key`_.os.cmd)in cmd
.os.name<>`unknown
.os.type in`l`m`s`v`w
.os.arch in`x86`x86_64
pwd:.os.pwd`
n:3
n sublist .os.env`
n sublist .os.ver`
n sublist .os.nproc`
pwd~.os.cd`
.os.rmrf tmp:"tmp"
.os.cd tmp
/.os.ls dir:"dir not exist" / fail
.os.cd dir:"dir not exist"
.os.cd".."
.os.ls dir
.os.rmrf dir
.os.mkdir dirs:("dir1";"dir2";"dir3 with space";"dir4/nested";"dir5 nested/deeper/with space")
allExist .q.Hsym dirs
.tree.tree`:.
.os.rmdir indvDirs:raze -1_'{"/"sv -1_"/"vs x}\'[dirs]
notAnyExist .q.Hsym indvDirs

.os.mkdir dirs
.os.touch files:("file1";"file2";"file3 with space";"dir4/nested/file4";"dir5 nested/deeper/with space/file5")
.tree.tree`:.
allExist .q.Hsym combined:dirs,files
.os.rmrf root:{first"/"vs x}each combined
notAnyExist .q.Hsym combined:dirs,files

.os.mkdir nums:101+til 10
allExist .q.Hsym nums:string nums
.os.rmdir nums
.os.mkdir syms:10?`8
allExist .q.Hsym string syms
.os.rmdir syms

.os.touch files:(prefix:"file"),/:nums
.os.mkdir dir:"dir"
/.os.cp files / fail
.os.cp files,enlist dir
.os.cp(prefix,"*";dir) / regex strings
(`$files)~key .q.Hsym dir

/
.os.mkdir joinedStrDirs
rootSplitStrDirs:{quoteIfSpace first"/"vs x}each splitStrDirsNoQuote
rootJoinedStrDirs:joinStr rootSplitStrDirs
.os.rmrf rootJoinedStrDirs
notAnyExist symDirs
.os.mkdir joinedStrDirs
destDir:"dir6"
.os.mkdir destDir
newRootJoinedStrDirs:joinStr(rootJoinedStrDirs;destDir)
if[not w;.os.cpr newRootJoinedStrDirs]
if[w;{.os.cpr joinStr(x;y)}[;destDir]'[rootSplitStrDirs]]
.os.cd destDir
allExist symDirs
.os.cd".."
.os.rmrf newRootJoinedStrDirs
splitStrFiles:.util.strPath each("file1";"\"file2 with space\"")
joinedStrFiles:joinStr splitStrFiles
strFile:first splitStrFiles
.os.touch strFile
.os.cp joinedStrFiles
splitStrFilesNoQuote:splitStrFiles except\:"\""
symFiles:.q.Hsym splitStrFilesNoQuote
allExist symFiles
.os.rm strFile
all@[.util.exists each symFiles;0;not]
.os.mv joinStr reverse splitStrFiles
lnJoinedStrFiles:joinStr$[w;reverse;]splitStrFiles
.os.ln lnJoinedStrFiles
allExist symFiles
textFile:`:test.txt; text:{100?.Q.an}each til 100
textFile 0:text
text~.os.cat textFile
search:`q
.os.where search
n sublist .os.pg search
st:.z.t
.os.sleep second:1
second<=`second$.z.t-st
.os.cd pwd
.os.rmrf tmp
system"d ."
delete from`.test
