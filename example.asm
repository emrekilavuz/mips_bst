.data

list : .word 50, 25, 75, 12, 33, 66, 83, 0
bosluk: .asciiz "\n"

.text
.globl main
main: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a1, list
	li $t1, 0
	jal loop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
loop:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a0, 0($a1)
	move $t0, $a0
	beq $t0, $t1, loop_exit
	li $v0, 1
	syscall
	la $a0, bosluk
	li $v0, 4
	syscall
	addi $a1, $a1, 4
	j loop
loop_exit:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
