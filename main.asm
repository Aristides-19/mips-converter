.include "macros.asm"
.include "data.asm"

.text
main:
    print_str(msg_newline)
    print_str(menu_in)
    read_int($s0) # $s0 = opción seleccionada por el usuario

    beq $s0, 7, end_prog
    
    print_str(msg_input)
    read_str(buffer, 100)

    la $a0, buffer # $a0 = dirección base del buffer de entrada

    beq $s0, 1, parse_bin

    print_str(msg_error)
    j main

# ============================================================
# SECTION RUTINAS DE PARSEO [STR (buffer) en $a0 -> INT en $s1 <- $v0]
# ============================================================
# NOTE No se valida el buffer de entrada, se asume que el formato es correcto

# FORMATO DE BUFFER -> 00000000000000001011001100111100 (sin espacios)
parse_bin:
    jal str_to_bin
    move $s1, $v0 # $s1 = entero interno representando el número ingresado
    j output

# !SECTION

output:
    print_str(menu_out)
    read_int($s0) # $s0 = opción seleccionada por el usuario

    print_str(msg_output)

    move $a0, $s1 # $a0 = entero interno a convertir a formato de salida
    la $ra, main

    beq $s0, 1, print_bin

    print_str(msg_error)
    j output

end_prog:
    li $v0, 10
    syscall

.include "formats/index.asm"