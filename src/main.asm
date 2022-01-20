%include "src/lib/io.inc"
%include "src/lib/lib.inc"
%include "src/lib/dict.asm"
%include "src/lib/colon.inc"

section .data
    %include "src/words.inc"
    
    %define WORD_BUFFER_SIZE 255
    WORD_BUFFER: times WORD_BUFFER_SIZE db 0
    
section .text

global _start
_start:
    xor rax, rax
    
    m_printn_str "Enter key to find (not more than 255 symbols): "
    m_print_str ">>> "
    
    mov rdi, WORD_BUFFER
    mov rsi, WORD_BUFFER_SIZE
    call read_word
    
    
    
    mov rdi, WORD_BUFFER
    mov rsi, CURRENT_START
    call find_word
    
    test rax, rax
    jz .not_found
    jmp .found
    .not_found:
        m_printn_str "Key not found."
        call exit
    .found:
        m_printn_str "Key found. Value:"
        mov rdi, rax
        add rdi, 8
        call string_length
        add rdi, rax
        inc rdi
        call print_string
    
    call exit