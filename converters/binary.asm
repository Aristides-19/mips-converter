.text
# NOTE Ya que se asume que el formato del buffer es correcto, no se hace un contador de bits recorridos
str_to_bin:
    li $v0, 0
stb_loop:
    # Cargar el byte actual del string (char)
    lb $t0, 0($a0)

    # Loop End
    beq $t0, 10, stb_end # \n
    beq $t0, 0, stb_end # 0 (fin de string)

    # Convertir char '0' o '1' a su valor numérico (0 o 1)
    addi $t0, $t0, -48

    sll $v0, $v0, 1
    or $v0, $v0, $t0

    # Avanzar puntero
    addi $a0, $a0, 1
    j stb_loop
stb_end:
    jr $ra