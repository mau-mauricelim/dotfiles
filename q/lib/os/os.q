/######
/# OS #
/######
// INFO: Inspired by https://github.com/BuaBook/kdb-common/blob/master/src/os.q
// NOTE: Windows commands: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/
// NOTE: The following windows commands do not have a verbose option: mkdir, rmdir
// WARN: Path with spaces need to be quoted

.os.name:$[.z.o~`l64arm;`linuxArm;.z.o like"l*";`linux;.z.o like"m*";`macOS;.z.o like"s*";`solaris;.z.o like"v*";`solarisIntel;.z.o like"w*";`windows;`unknown];
.os.type:`$first string .z.o;
.os.bits:"I"$string[.z.o]1 2;
.os.arch:`x86`x86_64 32 64i?.os.bits;

.os.strPath.l:.util.strPath;
.os.strPath.w:.util.strPathWin;

.os.run:{[cmd;x]
    if[(::)~c:.os.cmd cmd;'cmd];
    if[(::)~c@:.os.type;'cmdType];
    .log.system c .os.strPath[.os.type]x};

.os.cmd.pwd.w:.os.cmd.pwd.l:{"cd"};

.os.cmd.env.l:{"env"};
.os.cmd.env.w:{"set"};

.os.cmd.ver.l:{"cat /etc/os-release"};
.os.cmd.ver.w:{"ver"};

.os.cmd.nproc.l:{"nproc"};
.os.cmd.nproc.w:{"echo %NUMBER_OF_PROCESSORS%"};

.os.cmd.cd.w:.os.cmd.cd.l:"cd ",;

.os.cmd.ls.l:"ls ",;
.os.cmd.ls.w:"dir ",;

.os.cmd.mkdir.l:"mkdir -pv ",;
.os.cmd.mkdir.w:"mkdir ",;

.os.cmd.rmdir.l:"rmdir -v ",;
.os.cmd.rmdir.w:"rmdir ",;

.os.cmd.rm.l:"rm -v ",;
.os.cmd.rm.w:"del /s ",;
.os.cmd.rmrf.l:"rm -rfv ",;
.os.cmd.rmrf.w:{"del /f /s /q ",p," 2>nul & rmdir /s /q ",(p:x)," 2>nul & type nul"};

.os.cmd.mv.l:"mv -v ",;
.os.cmd.mv.w:"move /y ",;

.os.cmd.cp.l:"cp -v ",;
.os.cmd.cp.w:"copy /y ",;

.os.cmd.cpr.l:"cp -rv ",;
// WARN: Windows xcopy only allows 1 <source>
.os.cmd.cpr.w:{"xcopy /e /s /i /h /k /y /f ",p," 2>nul || copy /y ",(p:x)," 2>nul & type nul"};

.os.cmd.ln.l:"ln -sfv ",;
.os.cmd.ln.w:"mklink ",;

.os.cmd.head.l:"head ",;
.os.cmd.tail.l:"tail ",;

.os.cmd.cat.l:"cat ",;
.os.cmd.cat.w:"type ",;

.os.cmd.touch.l:"touch ",;
// WARN: Windows copy nul can only create one file at a time
.os.cmd.touch.w:"copy nul ",;

.os.cmd.which.l:"which ",;

.os.cmd.where.l:"whereis ",;
.os.cmd.where.w:"where ",;

.os.cmd.pg.l:"ps -ef | grep ",;
.os.cmd.pg.w:"tasklist /FO CSV /NH | findstr ",;

/ SIGINT (Ctrl+C interrupt)
.os.cmd.sigint.l:"kill -INT ",; / kill -2

/ SIGTERM (graceful termination)
.os.cmd.sigterm.l:"kill -TERM ",; / kill -15
.os.cmd.sigterm.w:"taskkill /PID ",;

/ SIGKILL (force kill)
.os.cmd.sigkill.l:"kill -KILL ",; / kill -9
.os.cmd.sigkill.w:"taskkill /PID /F ",;

.os.cmd.sleep.l:"sleep ",;
.os.cmd.sleep.w:{"ping 127.0.0.1 -n ",(string 1+"J"$x)," >nul"};

/ Set .os.cmd.cmdName to .os.cmdName for .os.type
// NOTE: To generate a list of @global: (` sv,[`.os]@)@'key`_.os.cmd
/ @global `.os.pwd`.os.env`.os.ver`.os.nproc`.os.cd`.os.ls`.os.mkdir`.os.rmdir`.os.rm`.os.rmrf`.os.mv`.os.cp`.os.cpr`.os.ln`.os.head`.os.tail`.os.cat`.os.touch`.os.which`.os.where`.os.pg`.os.sigint`.os.sigterm`.os.sigkill`.os.sleep
{{(` sv`.os,x)set .os.run x}each cmds:key(`_.os.cmd)[;.os.type];}[];
