.include "macros.asm"
.include "data.asm"

.text
main:
    print_str(msg_newline)
    print_str(menu_in)
    read_int($s0) # $s0 = opción seleccionada por el usuario

    beq $s0, 7, end_prog #salir del programa
    
    # opcion 6 fraccionario
    beq $s0, 6, parse_frac
    
    print_str(msg_input)
    read_str(buffer, 64)

    la $a0, buffer # $a0 = dirección base del buffer de entrada

    beq $s0, 1, parse_bin #binario en complemento a 2
    beq $s0, 2, parse_packed # decimal empaquetado
    beq $s0, 3, parse_dec #base 10
    beq $s0, 4, parse_oct #octal
    beq $s0, 5, parse_hex #hexadecimal
   

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

# ebtrada esperada : 00000000000000000000010100111100
parse_packed:
	jal str_to_packed # convierte BCD empaquetado a entero en $v0
	move $s1, $v0
	j output


# FORMATO DE BUFFER -> [-/+]123456
parse_dec:
    jal str_to_dec
    move $s1, $v0
    j output
    
    
# entrada esperadaÑ "+52" o "-52"
parse_oct:
	jal str_to_oct #convierte string octal a entero $v0
	move $s1, $v0
	j output


# FORMATO DE BUFFER ->  [-/+]186A0 (sin espacios, mayusculas)
parse_hex:
    jal str_to_hex
    move $s1, $v0
    j output

# FORMATO DE BUFFER -> [-]2.75
parse_frac:
    # La opcion 6 (Fraccionario) procesa e imprime directo sin pasar por 'output'
    print_str(msg_input)
    read_str(buffer, 64)
    print_str(msg_output)
    la $a0, buffer # Restaurar $a0 con el buffer de entrada
    jal dec_to_bin_frac
    j main

# !SECTION

output:
    print_str(menu_out)
    read_int($s0) # $s0 = opción seleccionada por el usuario

    print_str(msg_output)

    move $a0, $s1 # $a0 = entero interno a convertir a formato de salida
    la $ra, main

    beq $s0, 1, print_bin
    beq $s0, 2, print_packed
    beq $s0, 3, print_dec
    beq $s0, 4, print_oct
    beq $s0, 5, print_hex

    print_str(msg_error)
    j output

end_prog:
    li $v0, 10
    syscall

.include "formats/index.asm"
