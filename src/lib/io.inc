%ifndef IO

%include "src/lib/lib.inc"

;macros to ez print messages
%macro m_print_str 1
    section .data
        %%str db %1, 0
    
    section .text
        push rax
        push rdi
        push rsi
        push rdx
        push rcx

        mov rdi, %%str
        call print_string

        pop rcx
        pop rdx
        pop rsi
        pop rdi
        pop rax
        
%endmacro

%macro m_printn_str 1
    section .data
        %%str db %1, 0
    
    section .text
        push rax
        push rdi
        push rsi
        push rdx
        push rcx

        mov rdi, %%str
        call print_string
        call print_newline

        pop rcx
        pop rdx
        pop rsi
        pop rdi
        pop rax
        
%endmacro

;macros to ez print registers
%macro m_print_reg 1

        push rax
        push rdi
        push rsi
        push rdx
        push rcx

        push %1
        mov rdi, [rsp]
        call print_uint
        call print_newline
        pop rax

        pop rcx
        pop rdx
        pop rsi
        pop rdi
        pop rax
        
        
%endmacro

%define IO
%endif
