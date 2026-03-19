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

    la $a0, buffer # $a0 = dirección base del buffer de entrada

    beq $s0, 1, parse_bin

# ============================================================
# SECTION RUTINAS DE PARSEO [STR (buffer) en $a0 -> INT en $s1 <- $v0]
# ============================================================
# NOTE No se valida el buffer de entrada, se asume que el formato es correcto

# FORMATO DE BUFFER -> 00000000000000001011001100111100 (sin espacios)
parse_bin:
    jal str_to_bin
    move $s1, $v0 # $s1 = entero interno representando el número ingresado

# !SECTION

end_prog:
    li $v0, 10
    syscall

.include "converters/binary.asm"