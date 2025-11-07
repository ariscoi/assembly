.data
    read_format: .asciz "%d"
    print_format: .asciz "%d"
    debug_msg: .asciz "Valoare citită: %d\n"
    buffer: .long 0
    num_operations: .long 0
    tip_operatie: .long 0
    num_fisiere: .long 0
    file_id: .long 0
    file_size: .long 0
    debug_msg_interval: .asciz "%d: (%d, %d)\n"
    inceput_afisare: .long 0
    cate_fisiere: .long 0
    num_fisiere2: .long 0
    storage_space: .space 4096
    debug_msg_interval2: .asciz "(%d, %d)\n"
    debug_msg2: .asciz "Nu există suficient spațiu pentru fișier\n"


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
    mov $0, %edx
read_loop:
    xor %ecx, %ecx
    xor %eax, %eax
    mov num_operations, %eax
    test %eax, %eax
    jz close_program
    lea buffer, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov buffer, %ebx
    mov %ebx, tip_operatie
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
    cmp $4, %ebx
    je defragmentare

adaugare:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %esi
    lea buffer, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov buffer, %ebx
    mov %ebx, num_fisiere
    mov %ebx, num_fisiere2

adaugare_n_fisiere:
    xor %ecx, %ecx
    mov num_fisiere, %edx
    cmp $0, %edx
    je read_loop_2
    lea buffer, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov buffer, %ebx
    mov %ebx, file_id
    lea buffer, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov buffer, %eax
    add $7, %eax
    xor %edx, %edx
    mov $8, %ecx
    div %ecx
    mov %eax, file_size
    mov num_fisiere, %edx
    sub $1, %edx
    mov %edx, num_fisiere
    mov $0, %ecx
    jmp adaugare_in_storage
adaugare_in_storage:
    xor %esi, %esi
    xor %edx, %edx
    xor %ecx, %ecx
cauta_spatiu:
    cmp $1024, %ecx
    je nospace
    mov (%edi, %ecx, 4), %ebx
    cmp $0, %ebx
    je continua_cautarea
    xor %esi, %esi
    inc %ecx
    jmp cauta_spatiu

continua_cautarea:
    inc %esi
    cmp file_size, %esi
    jne continua_cautarea_pas
    sub $1, %esi
    sub %esi, %ecx
    mov %ecx, %edx
    jmp scrie_valoarea

continua_cautarea_pas:
    inc %ecx
    jmp cauta_spatiu

scrie_valoarea:
    mov file_id, %ebx
    mov file_size, %esi

scriere_loop:
    cmp $1025, %ecx
    je read_loop_2
    cmp $0, %esi
    je output_add
    mov %ebx, (%edi, %ecx, 4)
    inc %ecx
    dec %esi
    jmp scriere_loop
output_add:
    sub $1, %ecx
    push %ecx
    push %edx
    push %ebx
    push $debug_msg_interval
    call printf
    add $16, %esp
    push stdout
    call fflush
    add $4, %esp
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    jmp adaugare_n_fisiere
nospace:
    push $0
    push $0
    push file_id
    push $debug_msg_interval
    call printf
    add $16, %esp
    push stdout
    call fflush
    add $4, %esp
    jmp adaugare_n_fisiere
get:
    xor %ecx, %ecx
    lea storage_space, %edi
    lea buffer, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov buffer, %ebx
    xor %esi, %esi
    xor %eax, %eax
get_loop:
    cmp $1024, %ecx
    je not_found
    mov (%edi, %ecx, 4), %eax
    cmp %eax, %ebx
    je inceput_get
    inc %ecx
    jmp get_loop

inceput_get:
    mov %ecx, %esi
    jmp continuare_get
continuare_get:
    inc %ecx
    cmp %ecx, %edx
    je final_get
    mov (%edi, %ecx, 4), %eax
    cmp %eax, %ebx
    je continuare_get
    jmp final_get

final_get:
    sub $1, %ecx
    push %ecx
    push %esi
    push $debug_msg_interval2
    call printf
    add $16, %esp
    push stdout
    call fflush
    add $4, %esp
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    jmp read_loop_2

not_found:
    push $0
    push $0
    push $debug_msg_interval2
    call printf
    add $16, %esp
    push stdout
    call fflush
    add $4, %esp
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    jmp read_loop_2

delete:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %esi
    xor %ecx, %ecx
    lea storage_space, %edi
    lea buffer, %eax
    push %eax
    push $read_format
    call scanf
    add $8, %esp
    mov buffer, %ebx
    xor %esi, %esi
    xor %eax, %eax
    mov $0, %edx
delete_loop:
    cmp $1024, %ecx
    je finalizare
    mov (%edi, %ecx, 4), %eax
    cmp %eax, %ebx
    jne increment_index
    inc %esi
    mov %edx, (%edi, %ecx, 4)
    inc %ecx
    jmp delete_loop
increment_index:
    inc %ecx
    jmp delete_loop
finalizare:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %esp
    xor %esi, %esi
    jmp print_rest

print_rest:
    xor %ecx, %ecx
    lea storage_space, %edi
    mov $0, %ebx
scan_storage:
    cmp $1024, %ecx
    je read_loop_2
    mov (%edi, %ecx, 4), %eax
    cmp $0, %eax
    je indexare
    cmp %ebx, %eax
    je indexare
    cmp $0, %eax
    jne gasit_id
indexare:
    inc %ecx
    jmp scan_storage
gasit_id:
    mov %eax, %ebx
    mov %ecx, %esi
    jmp gasire_interval
gasire_interval:
    inc %ecx
    mov (%edi, %ecx, 4), %eax
    cmp %ebx, %eax
    jne printare
    jmp gasire_interval
printare:
    sub $1, %ecx
    push %ecx
    push %esi
    push %ebx
    push $debug_msg_interval
    call printf
    add $8, %esp
    push stdout
    call fflush
    add $4, %esp
    pop %ecx
    inc %ecx
    jmp scan_storage
defragmentare:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %esi

    lea storage_space, %edi
    xor %ecx, %ecx
    xor %edx, %edx
verificare_mem:
    cmp $1024, %ecx
    je mem_goala
    mov (%edi, %ecx, 4), %eax
    cmp $0, %eax
    jne defragmentare_preg
    inc %ecx
    jmp verificare_mem
mem_goala:
    jmp read_loop_2
    push $0
    push $0
    push $debug_msg_interval2
    call printf
    add $12, %esp

    push stdout
    call fflush
    add $4, %esp
    jmp read_loop_2
defragmentare_preg:
    lea storage_space, %edi
    xor %ecx, %ecx
    xor %edx, %edx
defragmentare_loop:
    cmp $1024, %ecx
    je defragmentare_end

    mov (%edi, %ecx, 4), %eax
    test %eax, %eax
    jz defragmentare_skip

    mov (%edi, %ecx, 4), %eax
    mov %eax, (%edi, %edx, 4)
    inc %edx

defragmentare_skip:
    inc %ecx
    jmp defragmentare_loop

defragmentare_end:
    mov $0, %eax
    cmp $1024, %edx
    je defragmentare_done

    mov %edx, %ecx
    jmp defragmentare_fill_zeros

defragmentare_fill_zeros:
    cmp $1024, %ecx
    je defragmentare_done
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    jmp defragmentare_fill_zeros

defragmentare_done:
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    jmp print_rest

close_program:
    pushl $0
    call fflush
    popl %eax

    mov $1, %eax
    xor %ebx, %ebx
    int $0x80