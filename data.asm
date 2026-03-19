.data
    menu_in: .asciiz "\n--- CONVERSOR PANITA ---\nSeleccione formato de entrada:\n1. Binario (C2)\n2. Decimal Empaquetado (Binario)\n3. Base 10\n4. Octal\n5. Hexadecimal\n6. Fraccionario (Dec->Bin)\n7. Salir\nOpción: "
    menu_out: .asciiz "\nSeleccione formato de salida:\n1. Binario (C2)\n2. Decimal Empaquetado (Binario)\n3. Base 10\n4. Octal\n5. Hexadecimal\nOpción: "
    msg_input: .asciiz "Ingrese numero: "
    msg_output: .asciiz "Resultado: "
    msg_error: .asciiz "Entrada invalida.\n"
    msg_newline: .asciiz "\n"
    
    # Técnicamente el número más grande será de 32 bits pero habría que verificar el buffer primero
    buffer: .space 64