/######
/# OS #
/######
// INFO: Inspired by https://github.com/BuaBook/kdb-common/blob/master/src/os.q
// NOTE: The following windows commands do not have a verbose option: mkdir, rmdir

.os.name:$[.z.o~`l64arm;`linuxArm;.z.o like"l*";`linux;.z.o like"m*";`macOS;.z.o like"s*";`solaris;.z.o like"v*";`solarisIntel;.z.o like"w*";`windows;`unknown];
.os.type:`$first string .z.o;
.os.bits:"I"$string[.z.o]1 2;
.os.arch:`x86`x86_64 32 64i?.os.bits;

.os.strPath.l:.util.strPath;
.os.strPath.w:.util.strPathWin;

.os.run:{[cmd;x]
    if[(::)~f:.os.cmd cmd;'cmd];
    if[(::)~f@:.os.type;'cmdType];
    .log.system f x};

// INFO: Filepath argument: "example", `example or `:example are equivalent
.os.i.transform:" "sv;
.os.i.mkCmd:{[minArgs;maxArgs;transform;cmd;args]
    args,:();
    / Ensure args is a list of strings
    if[10h~abs type args;args:enlist args];
    if[not count[args]within minArgs,maxArgs;'.log.error"Invalid number of arguments"];
    args:(.os.strPath[.os.type]each args)except enlist"";
    args:({$[" "in x;.util.addQuotes;]x}.util.removeQuotes@)each args;
    cmd transform args};

.os.cmd.pwd.w:.os.cmd.pwd.l:.os.i.mkCmd[0;0W;.os.i.transform;{"cd"}];

.os.cmd.env.l:.os.i.mkCmd[0;0W;.os.i.transform;{"env"}];
.os.cmd.env.w:.os.i.mkCmd[0;0W;.os.i.transform;{"set"}];

.os.cmd.ver.l:.os.i.mkCmd[0;0W;.os.i.transform;{"cat /etc/os-release"}];
.os.cmd.ver.w:.os.i.mkCmd[0;0W;.os.i.transform;{"ver"}];

.os.cmd.nproc.l:.os.i.mkCmd[0;0W;.os.i.transform;{"nproc"}];
.os.cmd.nproc.w:.os.i.mkCmd[0;0W;.os.i.transform;{"echo %NUMBER_OF_PROCESSORS%"}];

// WARN: Side effect: creates the directory if it does not exist
.os.cmd.cd.w:.os.cmd.cd.l:.os.i.mkCmd[0;1;.os.i.transform .util.removeQuotes@';"cd ",];

.os.cmd.ls.l:.os.i.mkCmd[0;0W;.os.i.transform;"ls ",];
.os.cmd.ls.w:.os.i.mkCmd[0;0W;.os.i.transform;"dir ",];

.os.cmd.mkdir.l:.os.i.mkCmd[0;0W;.os.i.transform;"mkdir -pv ",];
.os.cmd.mkdir.w:.os.i.mkCmd[0;0W;.os.i.transform;"mkdir ",];

.os.cmd.rmdir.l:.os.i.mkCmd[0;0W;.os.i.transform;"rmdir -v ",];
.os.cmd.rmdir.w:.os.i.mkCmd[0;0W;.os.i.transform;"rmdir ",];

.os.cmd.rm.l:.os.i.mkCmd[0;0W;.os.i.transform;"rm -v ",];
.os.cmd.rm.w:.os.i.mkCmd[0;0W;.os.i.transform;"del /s ",];

.os.cmd.rmrf.l:.os.i.mkCmd[0;0W;.os.i.transform;"rm -rfv ",];
.os.cmd.rmrf.w:.os.i.mkCmd[0;0W;.os.i.transform;{"del /f /s /q ",p," 2>nul & rmdir /s /q ",(p:x)," 2>nul & type nul"}];

.os.cmd.mv.l:.os.i.mkCmd[2;0W;.os.i.transform;"mv -v ",];
.os.cmd.mv.w:.os.i.mkCmd[2;2;.os.i.transform;"move /y ",];

.os.cmd.cp.l:.os.i.mkCmd[2;0W;.os.i.transform;"cp -v ",];
.os.cmd.cp.w:.os.i.mkCmd[2;2;.os.i.transform;"copy /y ",];

.os.cmd.cpr.l:.os.i.mkCmd[2;0W;.os.i.transform;"cp -rv ",];
.os.cmd.cpr.w:.os.i.mkCmd[2;2;.os.i.transform;{"xcopy /e /s /i /h /k /y /f ",p," 2>nul || copy /y ",(p:x)," 2>nul & type nul"}];

.os.cmd.ln.l:.os.i.mkCmd[2;2;.os.i.transform;"ln -sfv ",];
.os.cmd.ln.w:.os.i.mkCmd[2;2;.os.i.transform reverse@;"mklink ",];

.os.cmd.head.l:.os.i.mkCmd[1;0W;.os.i.transform;"head ",];

.os.cmd.tail.l:.os.i.mkCmd[1;0W;.os.i.transform;"tail ",];

.os.cmd.cat.l:.os.i.mkCmd[1;0W;.os.i.transform;"cat ",];
.os.cmd.cat.w:.os.i.mkCmd[1;0W;.os.i.transform;"type ",];

// TEST: 
.os.cmd.touch.l:.os.i.mkCmd[1;0W;.os.i.transform;"touch ",];
/.os.cmd.touch.w:.os.i.mkCmd[1;1;(::);"copy nul ",];
/{each[x;y]}[;]"touch ",/:files:("file1";"file2";"file3 with space";"dir4/nested/file4";"dir5 nested/deeper/with space/file5")

.os.cmd.which.l:.os.i.mkCmd[1;0W;.os.i.transform;"which ",];

.os.cmd.where.l:.os.i.mkCmd[1;0W;.os.i.transform;"whereis ",];
.os.cmd.where.w:.os.i.mkCmd[1;0W;.os.i.transform;"where ",];

.os.cmd.pg.l:.os.i.mkCmd[1;1;.os.i.transform;"ps -ef | grep ",];
.os.cmd.pg.w:.os.i.mkCmd[1;1;.os.i.transform;"tasklist /FO CSV /NH | findstr ",];

/ SIGINT (Ctrl+C interrupt)
.os.cmd.sigint.l:.os.i.mkCmd[1;0W;.os.i.transform;"kill -INT ",]; / kill -2

/ SIGTERM (graceful termination)
.os.cmd.sigterm.l:.os.i.mkCmd[1;0W;.os.i.transform;"kill -TERM ",]; / kill -15
.os.cmd.sigterm.w:.os.i.mkCmd[1;1;.os.i.transform;"taskkill /PID ",];

/ SIGKILL (force kill)
.os.cmd.sigkill.l:.os.i.mkCmd[1;0W;.os.i.transform;"kill -KILL ",]; / kill -9
.os.cmd.sigkill.w:.os.i.mkCmd[1;1;.os.i.transform;"taskkill /PID /F ",];

.os.cmd.sleep.l:.os.i.mkCmd[1;1;.os.i.transform;"sleep ",];
.os.cmd.sleep.w:.os.i.mkCmd[1;1;.os.i.transform;{"ping 127.0.0.1 -n ",(string 1+"J"$.util.removeQuotes x)," >nul"}];

/ Set .os.cmd.cmdName to .os.cmdName for .os.type
// NOTE: To generate a list of @global: (` sv,[`.os]@)@'key`_.os.cmd
/ @global `.os.pwd`.os.env`.os.ver`.os.nproc`.os.cd`.os.ls`.os.mkdir`.os.rmdir`.os.rm`.os.rmrf`.os.mv`.os.cp`.os.cpr`.os.ln`.os.head`.os.tail`.os.cat`.os.touch`.os.which`.os.where`.os.pg`.os.sigint`.os.sigterm`.os.sigkill`.os.sleep
{{(` sv`.os,x)set .os.run x}each cmds:key(`_.os.cmd)[;.os.type];}[];
