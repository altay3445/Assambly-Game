.data
    displayAddress: .word 0x10008000
    mushroomLocation: .word 200, 250, 300, 350, 400
    mushroomHealth: .word 2, 2, 2, 2, 2
    mushroomDirection: .word 1, 1, 1, 1, 1
    mushroomNum: .word 5
    shooterLocation: .word 992
    dartLocation: .word 0:10
    dartNum: .word 0
    gameOver: .word 0

.text
main:
    j loop

loop:
    lw $t0, gameOver
    bnez $t0, end_game
    jal clear_screen
    jal move_mushrooms
    jal disp_mushroom
    jal disp_shooter
    jal disp_dart
    jal check_keystroke
    jal set_dart_next
    jal check_dart_collision
    jal check_all_mushrooms_dead 
    jal check_shooter_collision
    jal delay
    j loop

end_game:
    j end_game

disp_shooter:
    la $t0, shooterLocation
    lw $t1, 0($t0)
    lw $t2, displayAddress
    sll $t1, $t1, 2
    add $t3, $t1, $t2
    li $t4, 0xFFFFFF
    sw $t4, 0($t3)
    jr $ra

disp_mushroom:
    la $t0, mushroomLocation
    la $t1, mushroomHealth
    la $t2, mushroomNum
    lw $t2, 0($t2)
    lw $t3, displayAddress

disp_mush_loop:
    beqz $t2, end_disp_mush
    lw $t4, 0($t0)
    lw $t5, 0($t1)
    beqz $t5, disp_next_mush
    li $t6, 0x00FF00
    beq $t5, 2, set_color
    li $t6, 0xFFA500
set_color:
    sll $t4, $t4, 2
    add $t7, $t4, $t3
    sw $t6, 0($t7)
disp_next_mush:
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, -1
    j disp_mush_loop
end_disp_mush:
    jr $ra

disp_dart:
    la $t0, dartLocation
    la $t1, dartNum
    lw $t1, 0($t1)
    lw $t2, displayAddress
    li $t3, 0xFF00FF
dart_loop:
    beqz $t1, end_dart
    lw $t4, 0($t0)
    sll $t4, $t4, 2
    add $t5, $t4, $t2
    sw $t3, 0($t5)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j dart_loop
end_dart:
    jr $ra

move_mushrooms:
    la $t0, mushroomLocation
    la $t1, mushroomDirection
    la $t2, mushroomHealth
    la $t3, mushroomNum
    lw $t3, 0($t3)
move_mush_loop:
    beqz $t3, end_move
    lw $t7, 0($t2)
    beqz $t7, move_next_mush
    lw $t4, 0($t0)
    lw $t5, 0($t1)
    beqz $t5, move_left
    addi $t4, $t4, 1
    j check_bounds
move_left:
    addi $t4, $t4, -1
check_bounds:
    li $t7, 1023
    ble $t4, $t7, check_left_bound
    li $t5, 0
    sw $t5, 0($t1)
    j move_down
check_left_bound:
    bgez $t4, no_reverse
    li $t5, 1
    sw $t5, 0($t1)
move_down:
    addi $t4, $t4, 32
no_reverse:
    sw $t4, 0($t0)
move_next_mush:
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    addi $t3, $t3, -1
    j move_mush_loop
end_move:
    jr $ra

set_dart_next:
    la $t0, dartLocation
    la $t1, dartNum
    lw $t1, 0($t1)
    li $t2, 0
dart_update_loop:
    beq $t2, $t1, end_update
    sll $t3, $t2, 2
    add $t4, $t0, $t3
    lw $t5, 0($t4)
    addi $t5, $t5, -32
    bltz $t5, remove_dart
    sw $t5, 0($t4)
    addi $t2, $t2, 1
    j dart_update_loop
remove_dart:
    addi $t6, $t2, 1
remove_shift_loop:
    beq $t6, $t1, end_remove_shift
    sll $t7, $t6, 2
    add $t8, $t0, $t7
    lw $t7, 0($t8)
    addi $t8, $t8, -4
    sw $t7, 0($t8)
    addi $t6, $t6, 1
    j remove_shift_loop
end_remove_shift:
    addi $t1, $t1, -1
    la $t9, dartNum
    sw $t1, 0($t9)
    j dart_update_loop
end_update:
    jr $ra

check_dart_collision:
    la $t0, dartLocation
    la $t1, dartNum
    lw $t1, 0($t1)
    la $t2, mushroomLocation
    la $t3, mushroomHealth
    la $t4, mushroomNum
    lw $t4, 0($t4)
    li $t5, 0
dart_collision_loop:
    beq $t5, $t1, end_dart_collision
    sll $t6, $t5, 2
    add $t6, $t0, $t6
    lw $t7, 0($t6)
    li $t8, 0
    la $t2, mushroomLocation
    la $t3, mushroomHealth
collision_mush_loop:
    beq $t8, $t4, next_dart_check
    lw $t9, 0($t2)
    lw $s0, 0($t3)
    beqz $s0, collision_next_mush
    beq $t7, $t9, hit_mushroom
collision_next_mush:
    addi $t2, $t2, 4
    addi $t3, $t3, 4
    addi $t8, $t8, 1
    j collision_mush_loop
hit_mushroom:
    addi $s0, $s0, -1
    sw $s0, 0($t3)
    addi $s1, $t5, 1
hit_dart_shift_loop:
    beq $s1, $t1, end_hit_shift
    sll $s2, $s1, 2
    add $s3, $t0, $s2
    lw $s2, 0($s3)
    addi $s3, $s3, -4
    sw $s2, 0($s3)
    addi $s1, $s1, 1
    j hit_dart_shift_loop
end_hit_shift:
    addi $t1, $t1, -1
    la $t9, dartNum
    sw $t1, 0($t9)
    addi $t5, $t5, -1
next_dart_check:
    addi $t5, $t5, 1
    j dart_collision_loop
end_dart_collision:
    jr $ra

check_shooter_collision:
    la $t0, shooterLocation
    lw $t1, 0($t0)
    la $t2, mushroomLocation
    la $t3, mushroomHealth
    la $t4, mushroomNum
    lw $t4, 0($t4)
    li $t5, 0
shooter_collision_loop:
    beq $t5, $t4, end_shooter_collision
    lw $t6, 0($t2)
    lw $t7, 0($t3)
    beqz $t7, shooter_next_check
    li $t8, 992
    blt $t6, $t8, shooter_next_check
    li $t8, 1023
    bgt $t6, $t8, shooter_next_check
    li $t9, 1
    sw $t9, gameOver
    jr $ra
shooter_next_check:
    addi $t2, $t2, 4
    addi $t3, $t3, 4
    addi $t5, $t5, 1
    j shooter_collision_loop
end_shooter_collision:
    jr $ra

check_keystroke:
    lw $t0, gameOver
    bnez $t0, no_input
    li $t0, 0xFFFF0000
    lw $t1, 0($t0)
    beq $t1, 1, read_key
no_input:
    jr $ra
read_key:
    li $t0, 0xFFFF0004
    lw $t2, 0($t0)
    li $t3, 0x6A
    beq $t2, $t3, move_left_key
    li $t3, 0x6B
    beq $t2, $t3, move_right_key
    li $t3, 0x78
    beq $t2, $t3, fire_dart
    jr $ra
move_left_key:
    la $t0, shooterLocation
    lw $t1, 0($t0)
    addi $t1, $t1, -1
    li $t2, 992
    blt $t1, $t2, no_move_left
    sw $t1, 0($t0)
no_move_left:
    jr $ra
move_right_key:
    la $t0, shooterLocation
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    li $t2, 1023
    bgt $t1, $t2, no_move_right
    sw $t1, 0($t0)
no_move_right:
    jr $ra
fire_dart:
    la $t0, dartLocation
    la $t1, dartNum
    lw $t2, 0($t1)
    li $t3, 10
    beq $t2, $t3, too_many_darts
    la $t3, shooterLocation
    lw $t4, 0($t3)
    sll $t5, $t2, 2
    add $t6, $t0, $t5
    sw $t4, 0($t6)
    addi $t2, $t2, 1
    sw $t2, 0($t1)
too_many_darts:
    jr $ra

delay:
    li $v0, 32
    li $a0, 50
    syscall
    jr $ra

clear_screen:
    li $t0, 0x10008000
    li $t1, 0
clear_loop:
    li $t2, 0x000000
    sw $t2, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    li $t3, 1024
    bne $t1, $t3, clear_loop
    jr $ra

check_all_mushrooms_dead:
    la $t0, mushroomHealth
    li $t1, 5
check_mush_loop:
    beqz $t1, all_dead
    lw $t2, 0($t0)
    bnez $t2, not_all_dead
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j check_mush_loop
all_dead:
    li $t3, 1
    sw $t3, gameOver
    jal draw_win_message
    jr $ra
not_all_dead:
    jr $ra

draw_win_message:
    lw $t0, displayAddress
    li $t1, 0xFFFF00
    li $t2, 34
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 66
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 98
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 130
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 162
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 36
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 68
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 100
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 132
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 38
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    li $t2, 70
    sll $t2, $t2, 2
    add $t3, $t0, $t2
    sw $t1, 0($t3)
    jr $ra