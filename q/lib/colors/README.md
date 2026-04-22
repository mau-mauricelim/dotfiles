# 🌈 Colors

Utilites to add colors to the terminal

### Showcase

https://github.com/user-attachments/assets/38bdb323-6c2b-41a8-939a-f86c453e6ba0

## 📊 Color Chart

### Showcase

https://github.com/user-attachments/assets/9b211374-cf15-4f37-93f8-51eb8291c7e3

## 🎨 Syntax highlighter

### Showcase

https://github.com/user-attachments/assets/10d43e21-3d72-49fc-a998-c456ade87b4f

### Simple syntax highlighter

Without using this library, syntax highlighter can be easily enabled with these few lines of code:

- Terminal 24-bit RGB colors support
```q
/ Colors 105-230 looks quite vibrant
.hl.hl:{"\033[0;38;5;",string[105+abs@[type parse@;x;0N]],"m",x,"\033[0m"};
.z.pi:{
    if[(::)~r:get x;:(::)];
    -1{@[{raze .hl.hl each -4!x};x;x]}each"\n"vs -1_.Q.s r;
    };
```

- Terminal 8-bit 256 colors support:
```q
.hl.co:31 32 33 34 35 36 91 92 93 94 95 96;
.hl.hl:{"\033[0;38;2;",string[.hl.co mod[@[type parse@;x;0N];count .hl.co]],"m",x,"\033[0m"};
.z.pi:{
    if[(::)~r:get x;:(::)];
    -1{@[{raze .hl.hl each -4!x};x;x]}each"\n"vs -1_.Q.s r;
    };
```

#### Showcase

https://github.com/user-attachments/assets/4a1b773c-b681-47f6-a47c-0da158967699
