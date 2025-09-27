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

// TEST:
/ args:`
/ args:"single arg"
/ args:("first arg";"second arg")
/ args:""
.os.mkCmd:{[minArgs;maxArgs;transform;cmd;args]
    args,:();
    / Ensure args is a list of strings
    if[10h~abs type args;args:enlist args];
    if[not count[args]within minArgs,maxArgs;'.log.error"Invalid number of arguments"];
    args:(.os.strPath[.os.type]each args)except enlist"";
    args:({$[" "in x;.util.addQuotes;]x}.util.removeQuotes@)each args;
    cmd" "sv transform args};

.os.cmd.pwd.w:.os.cmd.pwd.l:.os.mkCmd[0;0W;(::);{"cd"}];

.os.cmd.env.l:.os.mkCmd[0;0W;(::);{"env"}];
.os.cmd.env.w:.os.mkCmd[0;0W;(::);{"set"}];

.os.cmd.ver.l:.os.mkCmd[0;0W;(::);{"cat /etc/os-release"}];
.os.cmd.ver.w:.os.mkCmd[0;0W;(::);{"ver"}];

.os.cmd.nproc.l:.os.mkCmd[0;0W;(::);{"nproc"}];
.os.cmd.nproc.w:.os.mkCmd[0;0W;(::);{"echo %NUMBER_OF_PROCESSORS%"}];

.os.cmd.cd.w:.os.cmd.cd.l:.os.mkCmd[0;1;.util.removeQuotes';"cd ",];

.os.cmd.ls.l:.os.mkCmd[0;0W;(::);"ls ",];
.os.cmd.ls.w:.os.mkCmd[0;0W;(::);"dir ",];

.os.cmd.mkdir.l:.os.mkCmd[0;0W;(::);"mkdir -pv ",];
.os.cmd.mkdir.w:.os.mkCmd[0;0W;(::);"mkdir ",];

.os.cmd.rmdir.l:.os.mkCmd[0;0W;(::);"rmdir -v ",];
.os.cmd.rmdir.w:.os.mkCmd[0;0W;(::);"rmdir ",];

.os.cmd.rm.l:.os.mkCmd[0;0W;(::);"rm -v ",];
.os.cmd.rm.w:.os.mkCmd[0;0W;(::);"del /s ",];

.os.cmd.rmrf.l:.os.mkCmd[0;0W;(::);"rm -rfv ",];
.os.cmd.rmrf.w:.os.mkCmd[0;0W;(::);{"del /f /s /q ",p," 2>nul & rmdir /s /q ",(p:x)," 2>nul & type nul"}];

.os.cmd.mv.l:.os.mkCmd[2;0W;(::);"mv -v ",];
.os.cmd.mv.w:.os.mkCmd[2;2;(::);"move /y ",];

.os.cmd.cp.l:.os.mkCmd[2;0W;(::);"cp -v ",];
.os.cmd.cp.w:.os.mkCmd[2;2;(::);"copy /y ",];

.os.cmd.cpr.l:.os.mkCmd[2;0W;(::);"cp -rv ",];
.os.cmd.cpr.w:.os.mkCmd[2;2;(::);{"xcopy /e /s /i /h /k /y /f ",p," 2>nul || copy /y ",(p:x)," 2>nul & type nul"}];

.os.cmd.ln.l:.os.mkCmd[2;2;(::);"ln -sfv ",];
.os.cmd.ln.w:.os.mkCmd[2;2;reverse;"mklink ",];

.os.cmd.head.l:.os.mkCmd[1;0W;(::);"head ",];

.os.cmd.tail.l:.os.mkCmd[1;0W;(::);"tail ",];

.os.cmd.cat.l:.os.mkCmd[1;0W;(::);"cat ",];
.os.cmd.cat.w:.os.mkCmd[1;0W;(::);"type ",];

.os.cmd.touch.l:.os.mkCmd[1;0W;(::);"touch ",];
.os.cmd.touch.w:.os.mkCmd[1;1;(::);"copy nul ",];

.os.cmd.which.l:.os.mkCmd[1;0W;(::);"which ",];

.os.cmd.where.l:.os.mkCmd[1;0W;(::);"whereis ",];
.os.cmd.where.w:.os.mkCmd[1;0W;(::);"where ",];

.os.cmd.pg.l:.os.mkCmd[1;1;(::);"ps -ef | grep ",];
.os.cmd.pg.w:.os.mkCmd[1;1;(::);"tasklist /FO CSV /NH | findstr ",];

/ SIGINT (Ctrl+C interrupt)
.os.cmd.sigint.l:.os.mkCmd[1;0W;(::);"kill -INT ",]; / kill -2

/ SIGTERM (graceful termination)
.os.cmd.sigterm.l:.os.mkCmd[1;0W;(::);"kill -TERM ",]; / kill -15
.os.cmd.sigterm.w:.os.mkCmd[1;1;(::);"taskkill /PID ",];

/ SIGKILL (force kill)
.os.cmd.sigkill.l:.os.mkCmd[1;0W;(::);"kill -KILL ",]; / kill -9
.os.cmd.sigkill.w:.os.mkCmd[1;1;(::);"taskkill /PID /F ",];

.os.cmd.sleep.l:.os.mkCmd[1;1;(::);"sleep ",];
.os.cmd.sleep.w:.os.mkCmd[1;1;(::);{"ping 127.0.0.1 -n ",(string 1+"J"$.util.removeQuotes x)," >nul"}];

/ Set .os.cmd.cmdName to .os.cmdName for .os.type
// NOTE: To generate a list of @global: (` sv,[`.os]@)@'key`_.os.cmd
/ @global `.os.pwd`.os.env`.os.ver`.os.nproc`.os.cd`.os.ls`.os.mkdir`.os.rmdir`.os.rm`.os.rmrf`.os.mv`.os.cp`.os.cpr`.os.ln`.os.head`.os.tail`.os.cat`.os.touch`.os.which`.os.where`.os.pg`.os.sigint`.os.sigterm`.os.sigkill`.os.sleep
{{(` sv`.os,x)set .os.run x}each cmds:key(`_.os.cmd)[;.os.type];}[];
