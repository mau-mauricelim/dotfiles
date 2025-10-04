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
    f x};

// INFO: @param args
/ Most of these functions can take argument of an atom or a (mixed) list.
/ - It supports most data types that can be converted to a string (path)
/   - Example: string/symbol/number/mixed (list)
/   - `"100"`, `` `100``, `` `:100`` and `100` are equivalent
/ - Some functions support regex strings (dependent on OS!)
/   - Example: `.os.cp("SOURCE_*";"DIRECTORY")`
.os.i.run:{[bounds;run;cmd;transform;args]
    args,:();
    / Ensure args is a list of strings
    if[10h~abs type args;args:enlist args];
    args:(.os.strPath[.os.type]each args)except enlist"";
    if[not count[args]within bounds;'.log.error"Invalid number of arguments"];
    args:({$[" "in x;.util.addQuotes;]x}.util.removeQuotes@)each args;
    / Defaults
    if[`~transform;transform:" "sv];
    if[`~run;run:.log.system];
    run cmd transform args};

.os.cmd.pwd.w:.os.cmd.pwd.l:.os.i.run[0 0W;`;{"cd"};`];

.os.cmd.env.l:.os.i.run[0 0W;`;{"env"};`];
.os.cmd.env.w:.os.i.run[0 0W;`;{"set"};`];

.os.cmd.ver.l:.os.i.run[0 0W;`;{"cat /etc/os-release"};`];
.os.cmd.ver.w:.os.i.run[0 0W;`;{"ver"};`];

.os.cmd.nproc.l:.os.i.run[0 0W;`;{"nproc"};`];
.os.cmd.nproc.w:.os.i.run[0 0W;`;{"echo %NUMBER_OF_PROCESSORS%"};`];

// WARN: Side effect: creates the directory if it does not exist
.os.cmd.cd.w:.os.cmd.cd.l:.os.i.run[0 1;`;"cd ",;" "sv .util.removeQuotes@'];

.os.cmd.ls.l:.os.i.run[0 0W;`;"ls ",;`];
.os.cmd.ls.w:.os.i.run[0 0W;`;"dir ",;`];

.os.cmd.mkdir.l:.os.i.run[1 0W;`;"mkdir -pv ",;`];
.os.cmd.mkdir.w:.os.i.run[1 0W;`;"mkdir ",;`];

.os.cmd.rmdir.l:.os.i.run[1 0W;`;"rmdir -v ",;`];
.os.cmd.rmdir.w:.os.i.run[1 0W;`;"rmdir ",;`];

.os.cmd.rm.l:.os.i.run[1 0W;`;"rm -v ",;`];
.os.cmd.rm.w:.os.i.run[1 0W;`;"del /s ",;`];

.os.cmd.rmrf.l:.os.i.run[1 0W;`;"rm -rfv ",;`];
.os.cmd.rmrf.w:.os.i.run[1 0W;`;{"del /f /s /q ",p," 2>nul & rmdir /s /q ",(p:x)," 2>nul & type nul"};`];

/ Transfer SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY
.os.i.transfer:{[f;args]
    tgt:last args;
    if[2<count args;if[not .util.isDir .q.Hsym tgt;'.log.error"target '",tgt,"': Not a directory"]];
    f[;tgt]'[-1_args]};

.os.cmd.mv.l:.os.i.run[2 0W;`;"mv -v ",;`];
.os.cmd.mv.w:.os.i.run[2 0W;.log.system@';"move /y ",/:;.os.i.transfer{x," ",y}];

.os.cmd.cp.l:.os.i.run[2 0W;`;"cp -v ",;`];
.os.cmd.cp.w:.os.i.run[2 0W;.log.system@';"copy /y ",/:;.os.i.transfer{x," ",y}];

.os.cmd.cpr.l:.os.i.run[2 0W;`;"cp -rv ",;`];
.os.cmd.cpr.w:.os.i.run[2 0W;.log.system@';(::);
    .os.i.transfer{"xcopy /e /s /i /h /k /y /f ",x," ",y,"\\",.util.filename[x]," 2>nul || copy /y ",x," ",y," 2>nul & type nul"}]; / xcopy dir1 dir2\dir1

.os.cmd.ln.l:.os.i.run[2 2;`;"ln -sfv ",;`];
.os.cmd.ln.w:.os.i.run[2 2;`;"mklink ",;" "sv reverse@];

.os.cmd.head.l:.os.i.run[1 0W;`;"head ",;`];

.os.cmd.tail.l:.os.i.run[1 0W;`;"tail ",;`];

.os.cmd.cat.l:.os.i.run[1 0W;`;"cat ",;`];
.os.cmd.cat.w:.os.i.run[1 0W;`;"type ",;`];

.os.cmd.touch.l:.os.i.run[1 0W;`;"touch ",;`];
.os.cmd.touch.w:.os.i.run[1 0W;.log.system@';"copy nul ",/:;(::)];

.os.cmd.which.l:.os.i.run[1 0W;`;"which ",;`];

.os.cmd.where.l:.os.i.run[1 0W;`;"whereis ",;`];
.os.cmd.where.w:.os.i.run[1 0W;`;"where ",;`];

.os.cmd.pg.l:.os.i.run[1 1;`;"ps -ef | grep ",;`];
.os.cmd.pg.w:.os.i.run[1 1;`;"tasklist /FO CSV /NH | findstr ",;`];

/ SIGINT (Ctrl+C interrupt)
.os.cmd.sigint.l:.os.i.run[1 0W;`;"kill -INT ",;`]; / kill -2

/ SIGTERM (graceful termination)
.os.cmd.sigterm.l:.os.i.run[1 0W;`;"kill -TERM ",;`]; / kill -15
.os.cmd.sigterm.w:.os.i.run[1 0W;.log.system@';"taskkill /PID ",/:;(::)];

/ SIGKILL (force kill)
.os.cmd.sigkill.l:.os.i.run[1 0W;`;"kill -KILL ",;`]; / kill -9
.os.cmd.sigkill.w:.os.i.run[1 0W;.log.system@';"taskkill /PID /F ",/:;(::)];

.os.cmd.sleep.l:.os.i.run[1 1;`;"sleep ",;`];
.os.cmd.sleep.w:.os.i.run[1 1;`;{"ping 127.0.0.1 -n ",(string 1+"J"$.util.removeQuotes x)," >nul"};`];

/ Set .os.cmd.cmdName to .os.cmdName for .os.type
// NOTE: To generate a list of @global: (` sv,[`.os]@)@'key`_.os.cmd
/ @global `.os.pwd`.os.env`.os.ver`.os.nproc`.os.cd`.os.ls`.os.mkdir`.os.rmdir`.os.rm`.os.rmrf`.os.mv`.os.cp`.os.cpr`.os.ln`.os.head`.os.tail`.os.cat`.os.touch`.os.which`.os.where`.os.pg`.os.sigint`.os.sigterm`.os.sigkill`.os.sleep
{{(` sv`.os,x)set .os.run x}each cmds:key(`_.os.cmd)[;.os.type];}[];
