[bits 16]
[org 0x7c00]

STAGE2_OFFSET equ 0x8000

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00      

load_stage2:
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 10          ; HUGE UPGRADE: Read 10 full sectors (5120 bytes of room!)
    mov ch, 0           
    mov dh, 0           
    mov cl, 2           ; Start reading from Sector 2
    mov bx, STAGE2_OFFSET 
    int 0x13            
    jc load_stage2      

    jmp STAGE2_OFFSET   

times 510-($-$$) db 0
dw 0xAA55
