%ifndef IO
    %include "src/lib/io.inc"
%endif

section .text
    find_word_d:  ;rdi - string, rsi - x1
        m_printn_str "----------- find word func ---------------"
        .loop:
            m_print_str "key to find: "
            call print_string
            call print_newline
        
            m_print_str "node: "
            m_print_reg rsi
            
            test rsi, rsi
            jz .not_found
            
            push rsi
            push rdi
            m_print_str "key of this node: "
            add rsi, 8
            mov rdi, rsi
            call print_string
            call print_newline
            pop rdi
            pop rsi
            
            push rsi
            push rdi
            
            add rsi, 8
            call string_equals
            
            pop rdi
            pop rsi
            
            test rax, rax
            jz .next
            jmp .found
            
        .not_found:
            m_printn_str "got zero-pointer node. end"
            m_printn_str "--------------------------"
            xor rax, rax
            ret
        .next:
            m_printn_str "---"
        
            push r9
            mov r9, qword[rsi]
            mov rsi, r9
            pop r9
            jmp .loop
        .found:
            m_printn_str "key found. rax now contains point to node"
            m_printn_str "--------------------------"
            mov rax, rsi
            ret
            
            
    find_word:  ;rdi - string, rsi - x1
        .loop:            
            test rsi, rsi
            jz .not_found
            
            push rsi
            
            
            add rsi, 8
            call string_equals
            
            
            pop rsi
            
            test rax, rax
            jz .next
            jmp .found
            
        .not_found:
            xor rax, rax
            ret
        .next:
            push r9
            mov r9, qword[rsi]
            mov rsi, r9
            pop r9
            jmp .loop
        .found:
            mov rax, rsi
            ret
            
            
            
            
            
            
        