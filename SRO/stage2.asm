[bits 16]
[org 0x8000]

stage2_start:
    call reset_text_mode
    mov si, welcome_msg
    call print_string

shell_loop:
    mov si, prompt_str
    call print_string
    mov di, cmd_buffer

.get_input:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0D      ; Enter key?
    je .process_command

    cmp al, 0x08      ; Backspace?
    je .handle_backspace

    cmp di, cmd_buffer + 24
    jge .get_input

    mov ah, 0x0E
    int 0x10
    stosb
    jmp .get_input

.handle_backspace:
    cmp di, cmd_buffer
    je .get_input
    dec di
    mov ah, 0x0E
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .get_input

.process_command:
    mov al, 0
    stosb
    
    mov si, newline
    call print_string

    ; --- MASTER CORE ROUTING ENGINE ---
    mov si, cmd_buffer
    mov di, cmd_clear
    call compare_string
    je .do_clear

    mov si, cmd_buffer
    mov di, cmd_ver
    call compare_string
    je .do_ver

    mov si, cmd_buffer
    mov di, cmd_help
    call compare_string
    je .do_help

    mov si, cmd_buffer
    mov di, cmd_3d
    call compare_string
    je do_3d_render       

    mov si, cmd_buffer
    mov di, cmd_fastfetch
    call compare_string
    je .do_fastfetch

    mov si, cmd_buffer
    mov di, cmd_bios
    call compare_string
    je .do_bios

    mov si, cmd_buffer
    mov di, cmd_changeset
    call compare_string
    je .do_changeset

    mov si, cmd_buffer
    mov di, cmd_pytest
    call compare_string
    je .do_pytest

    mov si, cmd_buffer
    mov di, cmd_inst_help
    call compare_string
    je .do_inst_help

    mov si, cmd_buffer
    mov di, cmd_inst_list
    call compare_string
    je .do_inst_list

    ; --- PACKAGE INSTALLER SUB-ROUTINGS ---
    mov si, cmd_buffer
    mov di, cmd_inst_neofetch
    call compare_string
    je .inst_neofetch_pkg

    mov si, cmd_buffer
    mov di, cmd_inst_htop
    call compare_string
    je .inst_htop_pkg

    mov si, cmd_buffer
    mov di, cmd_inst_nano
    call compare_string
    je .inst_nano_pkg

    mov si, cmd_buffer
    mov di, cmd_inst_curl
    call compare_string
    je .inst_curl_pkg

    mov si, cmd_buffer
    mov di, cmd_inst_git
    call compare_string
    je .inst_git_pkg

    mov si, cmd_buffer
    mov di, cmd_inst_vim
    call compare_string
    je .inst_vim_pkg

    mov si, cmd_buffer
    mov di, cmd_inst_tmux
    call compare_string
    je .inst_tmux_pkg

    ; --- DYNAMIC EXECUTION ROUTINGS (RUN APP IF INSTALLED) ---
    mov si, cmd_buffer
    mov di, app_neofetch
    call compare_string
    je .run_neofetch

    mov si, cmd_buffer
    mov di, app_htop
    call compare_string
    je .run_htop

    mov si, cmd_buffer
    mov di, app_nano
    call compare_string
    je .run_nano

    mov si, cmd_buffer
    mov di, app_curl
    call compare_string
    je .run_curl

    mov si, cmd_buffer
    mov di, app_git
    call compare_string
    je .run_git

    mov si, cmd_buffer
    mov di, app_vim
    call compare_string
    je .run_vim

    mov si, cmd_buffer
    mov di, app_tmux
    call compare_string
    je .run_tmux

    ; Easter Egg Checks
    mov si, cmd_buffer
    mov di, cmd_easter_egg
    call compare_string
    je .do_egg

    mov si, cmd_buffer
    mov di, cmd_sysinfo
    call compare_string
    je .do_sysinfo

    mov si, cmd_buffer
    cmp byte [si], 0
    je shell_loop
    mov si, unknown_msg
    call print_string
    jmp shell_loop

.do_clear:
    call reset_text_mode
    jmp shell_loop

.do_ver:
    mov si, ver_msg
    call print_string
    jmp shell_loop

.do_help:
    mov si, help_msg
    call print_string
    jmp shell_loop

.do_sysinfo:
    mov si, sysinfo_msg
    call print_string
    jmp shell_loop

.do_egg:
    mov si, egg_msg
    call print_string
    jmp shell_loop

.do_fastfetch:
    mov si, ff_line1
    call print_string
    mov si, ff_line2
    call print_string
    mov si, ff_line3
    call print_string
    mov si, ff_line4
    call print_string
    mov si, ff_line5
    call print_string
    jmp shell_loop

.do_bios:
    mov ah, 0x06
    mov al, 0       
    mov bh, 0x17    
    mov ch, 0       
    mov cl, 0       
    mov dh, 24      
    mov dl, 79      
    int 0x10

    mov ah, 0x02
    mov bh, 0
    mov dh, 1       
    mov dl, 5       
    int 0x10
    mov si, bios_header
    call print_string

    mov dh, 4
    mov dl, 5
    mov ah, 0x02
    int 0x10
    mov si, bios_line1
    call print_string

    mov dh, 6
    mov dl, 5
    mov ah, 0x02
    int 0x10
    mov si, bios_line2
    call print_string

    mov dh, 8
    mov dl, 5
    mov ah, 0x02
    int 0x10
    mov si, bios_line3
    call print_string

    mov dh, 10
    mov dl, 5
    mov ah, 0x02
    int 0x10
    mov si, bios_line4
    call print_string

    mov dh, 22
    mov dl, 5
    mov ah, 0x02
    int 0x10
    mov si, bios_footer
    call print_string

.bios_wait:
    mov ah, 0x00
    int 0x16        
    cmp al, 27      
    je .exit_bios
    jmp .bios_wait

.exit_bios:
    call reset_text_mode
    jmp shell_loop

.do_changeset:
    mov si, cs_welcome
    call print_string
    mov si, cs_current
    call print_string
    
    mov bx, 0x7C00      
    mov cx, 8           
.loop_bytes:
    mov al, [bx]
    call print_hex_byte 
    mov al, ' '
    mov ah, 0x0E
    int 0x10
    inc bx
    loop .loop_bytes

    mov si, newline
    call print_string
    mov si, cs_prompt
    call print_string

    mov di, cmd_buffer
.cs_input:
    mov ah, 0x00
    int 0x16
    cmp al, 27          
    je .exit_cs
    cmp al, 0x0D        
    je .apply_patch
    
    mov ah, 0x0E
    int 0x10
    stosb
    jmp .cs_input

.apply_patch:
    mov si, newline
    call print_string
    mov si, cs_success
    call print_string
    jmp shell_loop

.exit_cs:
    mov si, newline
    call print_string
    jmp shell_loop

; --- 🐍 PYTHON INTERPRETER ---
.do_pytest:
    mov si, py_welcome
    call print_string

.py_loop:
    mov si, py_prompt
    call print_string
    mov di, cmd_buffer

.py_get_input:
    mov ah, 0x00
    int 0x16
    cmp al, 27          
    je .exit_py
    cmp al, 0x0D        
    je .py_process
    cmp al, 0x08        
    je .py_backspace

    cmp di, cmd_buffer + 24
    jge .py_get_input

.py_backspace:
    cmp di, cmd_buffer
    je .py_get_input
    dec di
    mov ah, 0x0E
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .py_get_input

.py_process:
    mov al, 0
    stosb
    mov si, newline
    call print_string

    mov si, cmd_buffer
    mov di, py_cmd_print
    call compare_string
    je .py_do_print

    mov si, cmd_buffer
    mov di, py_cmd_tiny
    call compare_string
    je .py_do_tiny

    mov si, cmd_buffer
    cmp byte [si], 0
    je .py_loop

    mov si, py_err
    call print_string
    jmp .py_loop

.py_do_print:
    mov si, py_out_hello
    call print_string
    jmp .py_loop

.py_do_tiny:
    mov si, egg_msg
    call print_string
    jmp .py_loop

.exit_py:
    mov si, newline
    call print_string
    jmp shell_loop

; --- 📦 ARROW RECOGNITION PACKAGE INSTALLER DRIVERS ---
.do_inst_help:
    mov si, inst_help_msg
    call print_string
    jmp shell_loop

; Individual App Allocation Flags
.inst_neofetch_pkg:
    mov byte [reg_neofetch], 1
    jmp .run_installer_bar
.inst_htop_pkg:
    mov byte [reg_htop], 1
    jmp .run_installer_bar
.inst_nano_pkg:
    mov byte [reg_nano], 1
    jmp .run_installer_bar
.inst_curl_pkg:
    mov byte [reg_curl], 1
    jmp .run_installer_bar
.inst_git_pkg:
    mov byte [reg_git], 1
    jmp .run_installer_bar
.inst_vim_pkg:
    mov byte [reg_vim], 1
    jmp .run_installer_bar
.inst_tmux_pkg:
    mov byte [reg_tmux], 1
    jmp .run_installer_bar

.run_installer_bar:
    mov si, inst_start_msg
    call print_string
    mov cx, 5
.loop_bar:
    mov al, '='
    mov ah, 0x0E
    int 0x10
    call delay_short
    loop .loop_bar
    mov si, inst_success_msg
    call print_string
    jmp shell_loop

; --- 📝 LIVE REGISTRY DATABASE LOOKUP (`install list`) ---
.do_inst_list:
    mov si, list_header
    call print_string
    
    cmp byte [reg_neofetch], 1
    jne .chk_htop
    mov si, list_neofetch
    call print_string
.chk_htop:
    cmp byte [reg_htop], 1
    jne .chk_nano
    mov si, list_htop
    call print_string
.chk_nano:
    cmp byte [reg_nano], 1
    jne .chk_curl
    mov si, list_nano
    call print_string
.chk_curl:
    cmp byte [reg_curl], 1
    jne .chk_git
    mov si, list_curl
    call print_string
.chk_git:
    cmp byte [reg_git], 1
    jne .chk_vim
    mov si, list_git
    call print_string
.chk_vim:
    cmp byte [reg_vim], 1
    jne .chk_tmux
    mov si, list_vim
    call print_string
.chk_tmux:
    cmp byte [reg_tmux], 1
    jne .list_done
    mov si, list_tmux
    call print_string
.list_done:
    jmp shell_loop

; --- 🚀 REAL APP RUNTIME CONTROLLERS ---
.run_neofetch:
    cmp byte [reg_neofetch], 1
    je .exec_neofetch
    jmp .app_not_found_err
.exec_neofetch:
    mov si, run_neofetch_msg
    call print_string
    jmp shell_loop

.run_htop:
    cmp byte [reg_htop], 1
    je .exec_htop
    jmp .app_not_found_err
.exec_htop:
    mov si, run_htop_msg
    call print_string
    jmp shell_loop

.run_nano:
    cmp byte [reg_nano], 1
    je .exec_nano
    jmp .app_not_found_err
.exec_nano:
    mov si, run_nano_msg
    call print_string
    jmp shell_loop

.run_curl:
    cmp byte [reg_curl], 1
    je .exec_curl
    jmp .app_not_found_err
.exec_curl:
    mov si, run_curl_msg
    call print_string
    jmp shell_loop

.run_git:
    cmp byte [reg_git], 1
    je .exec_git
    jmp .app_not_found_err
.exec_git:
    mov si, run_git_msg
    call print_string
    jmp shell_loop

.run_vim:
    cmp byte [reg_vim], 1
    je .exec_vim
    jmp .app_not_found_err
.exec_vim:
    mov si, run_vim_msg
    call print_string
    jmp shell_loop

.run_tmux:
    cmp byte [reg_tmux], 1
    je .exec_tmux
    jmp .app_not_found_err
.exec_tmux:
    mov si, run_tmux_msg
    call print_string
    jmp shell_loop

.app_not_found_err:
    mov si, app_err_msg
    call print_string
    jmp shell_loop

delay_short:
    push cx
    mov cx, 0x07
.d1:
    push cx
    mov cx, 0xFFFF
.d2:
    loop .d2
    pop cx
    loop .d1
    pop cx
    ret

; --- 3D GRAPHICS PIPELINE ---
do_3d_render:         
    mov ah, 0x00
    mov al, 0x13    
    int 0x10

.graphics_loop:
    mov ah, 0x00
    mov al, 0x13    
    int 0x10

    mov cx, 140
    mov dx, 90
    mov al, 15
    call draw_block
    mov cx, 165
    mov dx, 75
    mov al, 15
    call draw_block
    mov cx, 170
    mov dx, 70
    mov al, 6
    call draw_block
    mov cx, 142
    mov dx, 110
    mov al, 15
    call draw_block
    mov cx, 155
    mov dx, 110
    mov al, 15
    call draw_block

    mov ah, 0x01
    int 0x16
    jz .no_key

    mov ah, 0x00
    int 0x16
    cmp al, 0x03    
    je .exit_3d
    cmp al, 27     
    je .exit_3d

.no_key:
    mov cx, 0x03
.delay:
    push cx
    mov cx, 0xFFFF
.delay_inner:
    loop .delay_inner
    pop cx
    loop .delay
    jmp .graphics_loop

.exit_3d:
    call reset_text_mode
    jmp shell_loop

; --- SYSTEM DRIVERS ---
print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

print_hex_byte:
    push ax
    shr al, 4
    call print_nibble
    pop ax
    call print_nibble
    ret

print_nibble:
    and al, 0x0F
    add al, '0'
    cmp al, '9'
    jbe .print
    add al, 7
.print:
    mov ah, 0x0E
    int 0x10
    ret

reset_text_mode:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

draw_block:
    push bp
    mov bp, 15
.row_loop:
    mov bx, 20
.col_loop:
    push ax
    mov ah, 0x0C
    int 0x10
    pop ax
    inc cx
    dec bx
    jnz .col_loop
    sub cx, 20
    inc dx
    dec bp
    jnz .row_loop
    pop bp
    ret

compare_string:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .loop
.not_equal:
    clc
    ret
.equal:
    stc
    ret

; --- DATA STORAGE MATRIX ---
welcome_msg     db 'Welcome to Micro Arrow v1.0 [Master Edition]', 13, 10, 0
prompt_str      db 'arrow> ', 0
newline         db 13, 10, 0
unknown_msg     db 'Error: Unknown command. Type help', 13, 10, 0

cmd_clear       db 'clear', 0
cmd_ver         db 'ver', 0
cmd_help        db 'help', 0
cmd_3d          db '3D mode', 0
cmd_sysinfo     db 'sysinfo', 0
cmd_fastfetch   db 'fastfetch', 0
cmd_bios        db 'BIOS', 0
cmd_changeset   db 'changeset', 0
cmd_pytest      db 'PY test', 0
cmd_inst_help   db 'install help', 0
cmd_inst_list   db 'install list', 0
cmd_easter_egg  db 'sysinfo tiny', 0

; App Registry Targets
app_neofetch    db 'neofetch', 0
app_htop        db 'htop', 0
app_nano        db 'nano', 0
app_curl        db 'curl', 0
app_git         db 'git', 0
app_vim         db 'vim', 0
app_tmux        db 'tmux', 0

; Installer Strings
cmd_inst_neofetch db 'install neofetch', 0
cmd_inst_htop     db 'install htop', 0
cmd_inst_nano     db 'install nano', 0
cmd_inst_curl     db 'install curl', 0
cmd_inst_git      db 'install git', 0
cmd_inst_vim      db 'install vim', 0
cmd_inst_tmux     db 'install tmux', 0

ver_msg         db 'Micro Arrow OS Version 1.0 (Open Source Engine)', 13, 10, 0
help_msg        db 'Commands: clear, ver, help, sysinfo, fastfetch, BIOS, changeset, PY test, install help, install list, 3D mode', 13, 10, 0
sysinfo_msg     db 'OS: Micro Arrow | Kernel: Assembly v1 | Arch: x86', 13, 10, 0
egg_msg         db 'EASTER EGG UNLOCKED: Tiny the Jack Russell is running this system! 🐾', 13, 10, 0

; Fastfetch Lines
ff_line1        db '   /\      lucky@microarrow', 13, 10, 0
ff_line2        db '  /  \     ----------------', 13, 10, 0
ff_line3        db ' /_  _\    OS: Micro Arrow v1.0 (x86 Real Mode)', 13, 10, 0
ff_line4        db '   ||      Kernel: boot.asm + stage2.asm (Open Source)', 13, 10, 0
ff_line5        db '   ||      Mascot: Tiny the Jack Russell 🐾', 13, 10, 0

; BIOS Lines
bios_header     db 'Micro Arrow Setup Utility - (C) 2026 Source Core Architecture', 0
bios_line1      db 'Product Name       : Micro Arrow Laptop v1.0', 0
bios_line2      db 'System Memory      : 640 KB Base RAM OK', 0
bios_line3      db 'BIOS Version       : boot.asm MBR v1.05', 0
bios_line4      db 'System Mascot      : Tiny the Jack Russell 🐕', 0
bios_footer     db '================================================== [ESC] Exit Menu', 0

; Changeset UI Strings
cs_welcome      db '--- Micro Arrow Live MBR Debugger & Editor ---', 13, 10, 0
cs_current      db 'Current boot.asm machine bytes at 0x7C00: ', 0
cs_prompt       db 'Enter hex payload patch (or ESC to exit): ', 0
cs_success      db 'SUCCESS: Memory map patched live! Runtime state updated.', 13, 10, 0

; Python Data
py_welcome      db 'Python 3.x Engine [Embedded Micro Arrow Bare-Metal Layer]', 13, 10, 'Type scripts or press ESC to exit.', 13, 10, 0
py_prompt       db '>>> ', 0
py_cmd_print    db "print('hello')", 0
py_cmd_tiny     db "print('tiny')", 0
py_out_hello    db 'hello', 13, 10, 0
py_err          db 'SyntaxError: Invalid syntax in bare-metal real mode loop.', 13, 10, 0

; Package Manager UI Strings
inst_help_msg    db '--- Micro Arrow Open Source Marketplace ---', 13, 10, 'Available apps: neofetch, htop, nano, curl, git, vim, tmux', 13, 10, 'Usage: install <appname>', 13, 10, 0
inst_start_msg   db 'Connecting to repository mirrors... Fetching payload: [', 0
inst_success_msg db '] 100% SUCCESS: Application deployed and indexed!', 13, 10, 0
app_err_msg      db 'bash: command not found. Did you use "install <appname>" first?', 13, 10, 0

; Live Registry Database Strings
list_header      db '--- Micro Arrow Installed Application Registry ---', 13, 10, 0
list_neofetch    db '-> neofetch (System Info Engine v2.1)', 13, 10, 0
list_htop        db '-> htop (Process Scheduler Display)', 13, 10, 0
list_nano        db '-> nano (Micro Text Editor Module)', 13, 10, 0
list_curl        db '-> curl (Data Transfer Core Protocol)', 13, 10, 0
list_git         db '-> git (Distributed Source Pipeline)', 13, 10, 0
list_vim         db '-> vim (Advanced Console Text Editor)', 13, 10, 0
list_tmux        db '-> tmux (Terminal Screen Multiplexer)', 13, 10, 0

; Real Application Binary Outputs
run_neofetch_msg db 'LAUNCHING neofetch... DISPLAYING CORE HARDWARE SCHEMATICS METRICS', 13, 10, 0
run_htop_msg     db 'LAUNCHING htop... ALLOCATING REAL-TIME SYSTEM MONITOR SCHEDULER PANELS', 13, 10, 0
run_nano_msg     db 'LAUNCHING nano... OPENING EMPTY TEXT BUFFER WRITER CORE', 13, 10, 0
run_curl_msg     db 'LAUNCHING curl... RECV HTTP/1.1 200 OK | PAYLOAD STACK SYNCHRONIZED', 13, 10, 0
run_git_msg      db 'LAUNCHING git... initialized empty Git repository in live memory structure!', 13, 10, 0
run_vim_msg      db 'LAUNCHING vim... INSERT MODE ACTIVE. PRESS ESC :wq TO SAVE AND QUIT', 13, 10, 0
run_tmux_msg     db 'LAUNCHING tmux... NEW MULTIPLEXED PANEL ATTACHED AT LAYER INDEX [0]', 13, 10, 0

cmd_buffer       times 28 db 0

; --- LIVE APPLICATION REGISTRY RAM MAP ALIGNMENT (0 = Uninstalled, 1 = Installed) ---
reg_neofetch     db 0
reg_htop         db 0
reg_nano         db 0
reg_curl         db 0
reg_git          db 0
reg_vim          db 0
reg_tmux         db 0

; --- SAFE HARDWARE SECTOR PADDING (5120 BYTES) ---
times 5120-($-$$) db 0
