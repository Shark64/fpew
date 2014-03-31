%include "os_dependent_stuff.asm"
section .data
c_vzeroall:       db 0xC5, 0xFC, 0x77
c_vbroadcastsd_h: db 0xC4, 0x62, 0x7D, 0x19
c_vbroadcastsd_l: db 0xC4, 0xE2, 0x7D, 0x19
c_vbroadcast_y2:  db 0x52
c_vmovupd_1:      db 0xC5, 0xFD, 0x10, 0x0E
c_vmuladd_0:      db 0xC5, 0xED, 0x59, 0xC1
                  db 0xC5, 0xFD, 0x58, 0xC3
c_vmuladd_l:      db 0xC5, 0xFD, 0x59, 0xC1
                  db 0xC5, 0xFD, 0x58, 0xC4
c_vmuladd_p:      db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
c_vadd_h:         db 0xC4, 0xC1, 0x7D, 0x58

c_store:          db 0xC5, 0xFD, 0x11, 0x07
c_loop:           db 0x48, 0x83, 0xC7, 0x20
                  db 0x48, 0x83, 0xC6, 0x20
                  db 0x48, 0xFF, 0xC9
                  db 0x0F, 0x85
                  db 0x00, 0x00, 0x00, 0x00
c_ret:            db 0xc3

section .text
global _gen_horner_d
global gen_horner_d
_gen_horner_d:
gen_horner_d:  ; argument: degree
  ; first compute length of code
  ; assume at least two coefficients (degree>=1), degree-1=k>=0
  ; 6 bytes of vbroadcastsd per coefficient
  ; 4 bytes of vaddpd
  ; 4 bytes of vmulpd for k<=5, thereafter 5
  ; fixed: 3 + 12 + 15 + 7 = 37 bytes
  ; 23+14*deg bytes, plus additional (deg-6) bytes if deg-6 > 0
  push rbp
  mov rbp, rsp
  and rsp, ~0xf

  xor rax, rax
  mov cx, di
  mov al, 14
  mul cl
  add ax, 23
  sub cl, 6
  js .skadd
  add ax, cx
  .skadd:

  push rdi
  ;  allocate region
  mov r10, MAP_SHARED|MAP_ANON     ; MAP_ANON means not backed by a file
  mov r8,  -1                      ; thus our file descriptor is -1
  mov r9,   0                      ; and there's no file offset in either case.
  mov rdx, PROT_READ|PROT_WRITE    ; We'd like a read/write mapping
  mov rdi,  0                      ; at no pre-specified memory location.
  mov rsi, rax                     ; Length of the mapping in bytes.
  push rax
  mov rax, SYSCALL_MMAP         
  syscall                        ; do mmap() system call.
  test rax, rax                  ; Return value will be in rax.
  js error                       ; If it's negative, that's trouble.
  pop r11
  pop rdi
  
  mov r10, rax

  mov edx, dword [c_vzeroall]
  mov dword [rax], edx
  add rax, 3

  mov cx, di
  mov si, di
  add cl, 2
  cmp cl, 8
  cmovs  edx, [c_vbroadcastsd_l]
  cmovns edx, [c_vbroadcastsd_h]
  and cx, 7
  shl cx, 3
  or  cl, 2
  mov dword [rax], edx
  mov word [rax+4], cx
  or cl, 0x40
  add rax, 5
.vb_put_lp:
  sub cl, 8
  test cl, 0x40
  jnz .vb_put_ok
  or   cl, 0x40
  mov edx, [c_vbroadcastsd_l]
.vb_put_ok:
  add ch, 8
  mov dword [rax], edx
  mov word [rax+4], cx
  add rax, 6
  dec si
  jnz .vb_put_lp

  mov edx, dword [c_vmovupd_1]
  mov dword [rax], edx
  mov r9, rax ; we need to jump back here later
  mov rdx, qword [c_vmuladd_0]
  mov qword [rax+4], rdx
  add rax, 12
  xor esi, esi
  mov rdx, qword [c_vmuladd_l]
  mov r8,  qword [c_vmuladd_p]
  push rdi
.ma_put_lp_l:
  dec di
  jz .ma_put_done
  mov qword [rax], rdx
  add rax, 8
  add rdx, r8
  inc esi
  cmp esi, 4
  jnz .ma_put_lp_l
  mov esi, dword [c_vadd_h]
  mov cl, 0xc0
.ma_put_lp_h:
  dec di
  jz .ma_put_done
  mov dword [rax], edx
  mov dword [rax+4], esi
  mov byte  [rax+8], cl
  inc cl
  add rax, 9
  jmp .ma_put_lp_h
.ma_put_done:
  mov edx, dword [c_store]
  mov dword [rax], edx
  add rax, 4
  movdqu xmm0, [c_loop]
  movdqu [rax], xmm0
  add rax, (c_ret-c_loop)
  mov rdx, r9
  sub rdx, rax 
  mov dword [rax-4], edx
  mov byte [rax], 0xc3

  pop rsi
  push r10
  mov rdi, r10
  mov rdx, PROT_EXEC|PROT_READ
  mov rax, SYSCALL_MPROTECT
  syscall
  test eax, eax
  js error
  pop rax
error:
  mov rsp, rbp
  pop rbp
  ret
