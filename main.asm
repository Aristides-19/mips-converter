.include "macros.asm"
.include "data.asm"

.text
main:
    print_str(menu_in)

    li $v0, 5
    syscall
    move $s0, $v0 # $s0 = opcion entrada

    beq $s0, 7, end_prog
    
    print_str(msg_input)
    read_str(buffer, 100)

    la $s1, buffer # $s1 = dirección base del buffer de entrada

end_prog:
    li $v0, 10
    syscall