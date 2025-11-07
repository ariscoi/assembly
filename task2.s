.data
    read_format: .asciz "%d"
    buffer: .long 0
    num_operations: .long 0
    tip_operatie: .long 0
    num_fisiere: .long 0
    file_id: .long 0
    file_size: .long 0
    debug_msg_interval: .asciz "%d: ((%d, %d), (%d, %d))\n"
    inceput_afisare: .long 0
    sfarsit_afisare: .long 0
    storage_space: .space 1024*1024*4
    debug_msg2: .asciz "((%d, %d), (%d, %d))\n"
    start_line: .long 0
    end_line: .long 0
    start_col: .long 0
    end_col: .long 0
    line: .long 0
    col: .long 0
    four_msg: .asciz "4\n"   
    contor:.long 0
.text
    .extern printf
    .extern scanf
    .extern exit
    .extern fflush
    .extern stdout
    .global main

main:
    lea storage_space, %edi
    lea num_operations, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
read_loop:
    xor %ecx, %ecx
    xor %eax, %eax
    mov num_operations, %eax
    test %eax, %eax
    jz close_program
    lea tip_operatie, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov tip_operatie, %ebx
    jmp alegem_operatia

read_loop_2:
    mov num_operations, %eax
    dec %eax
    mov %eax, num_operations
    jmp read_loop

alegem_operatia:
    cmp $1, %ebx
    je adaugare
    cmp $2, %ebx
    je get
    cmp $3, %ebx
    je delete
adaugare:
    # Citim nr_fisiere
    lea num_fisiere, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp

adaugare_n_fisiere:
    mov num_fisiere, %edx
    cmp $0, %edx
    je read_loop_2
    # Citim file_id
    lea file_id, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    # Citim file_size
    lea file_size, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov file_size, %eax
    add $7, %eax
    xor %edx, %edx
    mov $8, %ecx
    div %ecx
    mov %eax, file_size

    mov num_fisiere, %edx
    sub $1, %edx
    mov %edx, num_fisiere

    ;#file_size mai mare ca 1024
    cmp $1024, %eax
    jg spatiu_insuficient
    xor %ecx, %ecx
    xor %eax, %eax
    xor %ebx, %ebx
    mov %ecx, start_col
    mov $1024, %esi
    div %esi
    mov %eax, line
    mov %edx, col
    
    jmp search
search:
    mov line, %esi
    cmp $1024, %esi
    je spatiu_insuficient
    
    xor %edx, %edx
    mov $1024, %esi
    mov %ecx, %eax
    div %esi
    mov %eax, line
    mov %edx, col
    mov (%edi, %ecx, 4), %eax
    cmp $0, %eax
    je first_zero
    inc %ecx 
    jmp search

first_zero:
    ;#cautam intervalul
    mov file_size, %eax
    inc %ecx
    inc %ebx
    cmp %ebx, %eax
    jle reset
    mov (%edi, %ecx, 4), %eax
    cmp $0, %eax
    jne sari_la_inceput
    jmp continua

sari_la_inceput:
    mov $0, %ebx
    jmp search

reset:
    mov %ecx, end_col
    sub %ebx, %ecx
    mov $1024, %esi
    mov %ecx, %eax
    xor %edx, %edx
    div %esi
    mov %edx, start_col
    mov %edx, col
    mov %eax, line
    jmp add_file_id

continua:
    mov %ecx, %eax
    mov $1024, %esi
    xor %edx, %edx
    div %esi
    mov %eax, line
    mov %edx, col
    mov col, %esi
    cmp $0, %esi
    je sari_la_inceput
    jmp first_zero


add_file_id:
    ;#adaugam in matrice
    mov file_size, %esi
    cmp $0, %esi
    jle printare
    sub $1, %esi
    mov %esi, file_size
    mov $1024, %esi
    xor %edx, %edx
    mov %ecx, %eax
    div %esi
    mov %edx, col
    mov %eax, line
    mov %edx, end_col
    mov file_id, %eax
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    jmp add_file_id
printare:
    mov end_col, %eax      
    cmp $-1, %eax          
    jne continua_printare   

    mov $1023, %eax         
    mov %eax, end_col       

continua_printare:
    push end_col
    push line
    push start_col
    push line
    push file_id
    push $debug_msg_interval
    call printf
    add $24, %esp
    jmp adaugare_n_fisiere

spatiu_insuficient:
    push $0
    push $0
    push $0
    push $0
    push file_id
    push $debug_msg_interval
    call printf
    add $24, %esp
    xor %edx, %edx
    xor %ecx, %ecx
    xor %ebx, %ebx
    xor %esi, %esi
    jmp adaugare_n_fisiere
 get:
    # Citim file_id care trebuie căutat
    lea file_id, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    xor %edx, %edx
    mov $1024, %esi
    div %esi
    mov %eax, line
    mov %edx, col
get_loop:
    mov line, %esi
    cmp $1024, %esi
    je not_found
    xor %edx, %edx
    mov $1024, %esi
    mov %ecx, %eax
    div %esi
    mov %eax, line
    mov %edx, col

    mov %ebx, contor
    mov file_id, %ebx
    mov (%edi, %ecx, 4), %eax
    cmp %ebx, %eax
    je gasit_1
    mov contor, %ebx
    inc %ecx 
    jmp get_loop

gasit_1:
    mov %ecx, contor
    mov col, %ecx
    mov %ecx, start_col
    mov contor, %ecx
gasit:
    xor %edx, %edx
    mov %ecx, %eax
    div %esi
    mov %edx, end_col
    mov %ebx, contor
    mov file_id, %ebx
    inc %ecx
    mov (%edi, %ecx, 4), %eax
    cmp %ebx, %eax
    jne printare_get
    mov contor, %ebx
    jmp gasit
printare_get:
    push end_col
    push line
    push start_col
    push line
    push $debug_msg2
    call printf
    add $20, %esp
    xor %edx, %edx
    xor %ecx, %ecx
    xor %ebx, %ebx
    xor %esi, %esi
    jmp read_loop_2
not_found:
    push $0
    push $0
    push $0
    push $0
    push $debug_msg2
    call printf
    add $20, %esp
    xor %edx, %edx
    xor %ecx, %ecx
    xor %ebx, %ebx
    xor %esi, %esi
    jmp read_loop_2
delete:
    lea file_id, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    xor %edx, %edx
    mov $1024, %esi
    div %esi
    mov %eax, line
    mov %edx, col
    xor %ecx, %ecx
delete_loop:
    mov line, %esi
    cmp $1024, %esi
    je stai
    xor %edx, %edx
    mov $1024, %esi
    mov %ecx, %eax
    div %esi
    mov %eax, line
    mov %edx, col

    mov %ebx, contor
    mov file_id, %ebx
    mov (%edi, %ecx, 4), %eax
    cmp %ebx, %eax
    je gasit_2
    mov contor, %ebx
    inc %ecx 
    jmp delete_loop
gasit_2:
    mov file_id, %ebx
    mov $0, %eax
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    mov (%edi, %ecx, 4), %eax
    cmp %ebx, %eax
    jne stai
    jmp gasit_2
stai:
    xor %edx, %edx
    mov %edx, contor
printare_memorie:
    mov contor, %ecx
    sub $1, %ecx
    xor %edx, %edx
    mov $1024, %esi
    mov %ecx, %eax
    div %esi
    mov %eax, line
    mov %edx, col
cautam_fisiere:
    mov line, %esi
    cmp $1024, %esi
    je read_loop_2
    xor %edx, %edx
    mov $1024, %esi
    mov %ecx, %eax
    div %esi
    mov %eax, line
    mov %edx, col
    mov (%edi, %ecx, 4), %eax
    cmp $0, %eax
    je indexare
    cmp %ebx, %eax
    je indexare
    jmp gasit_fisier
indexare:
    inc %ecx
    jmp cautam_fisiere
gasit_fisier:
    mov %eax, %ebx
    mov %eax, file_id
    mov %edx, start_col
cautare_final:
    mov line, %esi
    cmp $1024, %esi
    je read_loop_2
    mov $1024, %esi
    mov %ecx, %eax
    xor %edx, %edx
    div %esi
    mov %eax, line
    mov %edx, end_col
    mov (%edi, %ecx, 4), %eax
    inc %ecx
    cmp %eax, %ebx
    jne printare_mem
    jmp cautare_final
printare_mem:
    mov %ecx, contor
    sub $1, %edx
    cmp $-1, %edx
    je problema
    jmp printare_mem2
problema:
    mov $1023, %edx
    mov line, %esi
    dec %esi
    mov %esi, line
    jmp printare_mem2
printare_mem2:
    mov %edx, end_col
    push end_col
    push line
    push start_col
    push line
    push %ebx
    push $debug_msg_interval
    call printf
    add $24, %esp
    xor %esi, %esi
    xor %edx, %edx
    jmp printare_memorie

 
close_program:
    pushl $0
    call fflush
    popl %eax

    mov $1, %eax
    xor %ebx, %ebx
    int $0x80