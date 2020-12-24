.data
# -9999 marks the end of the list
firstList: .word 8, 3, 6, 10, 13, 7, 4, 5, -9999

# other examples for testing your code
secondList: .word 8, 3, 6, 6, 10, 13, 7, 4, 5, -9999
thirdList: .word 8, 3, 6, 10, 13, -9999, 7, 4, 5, -9999

# assertEquals data
failf: .asciiz " failed\n"
passf: .asciiz " passed\n"
buildTest: .asciiz " Build test"
insertTest: .asciiz " Insert test"
findTest: .asciiz " Find test"
asertNumber: .word 0

tree: .word 0  ## address pointer
queue1_front: .word 0 ##  address pointer
queue1_rear: .word 0  ## address pointer
queue2_front: .word 0 ##  address pointer
queue2_rear: .word 0  ## address pointer
line: .asciiz "\n"
space: .asciiz " "
x: .asciiz "X"
output_level_order_tree: .asciiz "The numbers in level order:\n"
end_line_prompt: .asciiz "\n"

.text
.globl main
main:

    # The test code assumes your root node's address is stored at $s0 and at tree argument at all times
    # Although it's not needed, you can:
    #         - modify the test cases if you must
    #         - add code between test cases
    #

    lw $a2, tree
    la $a1, firstList
	li $t5, -9999

    # build a tree using the firstList
    jal build_beginning

    # Start of the test cases----------------------------------------------------
    lw $s0, tree
    # check build procedure
    lw $t0, 4($s0) # address of the left child of the root
    lw $a0, 0($t0) # real value of the left child of the root
    li $a1, 3 # expected value of the left child of the root
    la $a2, buildTest # the name of the test
    # if left child != 3 then print failed 
    jal assertEquals

    # check insert procedure
    li $a0, 11 # new value to be inserted
    lw $a2, tree # address of the root
    la $a1, firstList
    jal insert_beginning
    # no need to reload 11 to $a0
    lw $a1, 0($v0) # value from the returned address
    la $a2, insertTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure
    li $a0, 11 # search value
    move $a2, $s0 # adress of the root  ## my tree root at $a2
    jal find 
    # no need to reload 11 to $a0
    lw $a1, 0($v1) # value from the found adress
    la $a2, findTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure 2
    # 44 should not be on the list
    # v0 should return 1
    li $a0, 44 # search value
    move $a2, $s0 # adress of the root
    jal find
    move $a0, $v0 # result of the search
    li $a1, 1 # expected result of the search
    la $a2, findTest # the name of the test
    # if returned value of $v0 != 0 print failed
    jal assertEquals

    move $a0, $s0
    jal print_level_order # print tree for visual inspection

    # End of the test cases----------------------------------------------------

    # End program
    li $v0, 10
    syscall

assertEquals:
    addi $sp, $sp, -36
	sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $t2, 8($sp)
    sw $t0, 12($sp)
    sw $t1, 16($sp)
    sw $s0, 20($sp)
    sw $a0, 24($sp)
    sw $a1, 28($sp)
    sw $a2, 32($sp)

    move $t2, $a0
    # increment count of total assertions.
    la $t0, asertNumber
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0) 

    # print the test number
    add $a0, $t1, $zero
    li $v0, 1
    syscall
    
    # print the test name
    move $a0, $a2
    li $v0, 4
    syscall

    # print passed or failed.
    beq $t2, $a1, passed
    la $a0, failf
    li $v0, 4
    syscall
    j assert_return
passed:
    la $a0, passf
    li $v0, 4
    syscall
    j assert_return
assert_return:
	lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $t2, 8($sp)
    lw $t0, 12($sp)
    lw $t1, 16($sp)
    lw $s0, 20($sp)
    lw $a0, 24($sp)
    lw $a1, 28($sp)
    lw $a2, 32($sp)
    addi $sp, $sp, 36
    jr $ra


build_beginning:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $a0, 8($sp)
    sw $a1, 12($sp)
    sw $a2, 16($sp)

	lw $a0, 0($a1)
	jal initialize_tree_root
build:
	          ## $a0 first list value
	addi $a1, $a1, 4
	lw $a0, 0($a1)
	beq $a0, -9999, build_exit     ## if $a0 big negative value  
	jal insert_beginning
	
	j build
build_exit:
	lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $a0, 8($sp)
    lw $a1, 12($sp)
    lw $a2, 16($sp)
	addi $sp, $sp, 20
	jr $ra

#############################################################
#############################################################
initialize_tree_root:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal allocate_memory
	
    	sw $v0, tree
	
	# store current list value to root node of the tree
	sw $a0, 0($v0)
	
	# initialize head node's parent, left and right nodes to zero
	sw $zero, 4($v0)
	sw $zero, 8($v0)
	sw $zero, 12($v0)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


insert_beginning:
	# store return address
	addi $sp, $sp, -28
	sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
	sw $s0, 12($sp)
    sw $s1, 16($sp)
    sw $t4, 20($sp)
    sw $a0, 24($sp)
	# load root node of the tree
	lw $t0, tree
	add $t1, $zero, $zero

    lw $a2, tree
    jal find
    beq $v0, 0, insert_return

compare:
	beq $t0, $zero, create_node
	lw $s0, 0($t0)
	slt $t2, $a0, $s0
	beq $t2, $zero, goRight

goLeft:
	add $t1, $t0, $zero
	lw $t0, 4($t0)
	j compare

goRight:
	add $t1, $t0, $zero 
	lw $t0, 8($t0)
	j compare
	
create_node:
	jal allocate_memory
	lw $s1, 0($t1)
	slt $t4, $a0, $s1
	beq $t4, $zero, link_node_right
	
link_node_left:
    	sw $v0, 4($t1)
	j end_attach_if_else
	
link_node_right:
    	sw $v0, 8($t1)
	
end_attach_if_else:
	# initalize the current node value to the passed in argument on the $f12 register
	sw $a0, 0($v0)
	
	# initalize the current node next value to null
	sw $zero, 4($v0)
	sw $zero, 8($v0)
	sw $zero, 12($v0)
	
insert_return:
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
	lw $s0, 12($sp)
    lw $s1, 16($sp)
    lw $t4, 20($sp)
    lw $a0, 24($sp)
	addi $sp, $sp, 28
	jr $ra

##############################################################
##############################################################
find:
	addi $sp, $sp, -32    #### $a0 is the value to be found, $a2 tree root
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s0, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)

	move $t0, $a2

find_compare:
	beq $t0, $zero, not_found
	lw $s0, 0($t0)
	beq $s0, $a0, found
	slt $t2, $a0, $s0
	beq $t2, $zero, find_goRight

find_goLeft:
	add $t1, $t0, $zero
	lw $t0, 4($t0)
	j find_compare

find_goRight:
	add $t1, $t0, $zero 
	lw $t0, 8($t0)
	j find_compare
found:
	li $v0, 0
	move $v1, $t0
	j find_return

not_found:
	li $v0, 1
	j find_return
find_return:
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	addi $sp, $sp, 32
	jr $ra
#######################################################
#######################################################


#######################################################
#######################################################
print_level_order:
	addi $sp, $sp, -52
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $a0, 8($sp)
	sw $a3, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)
	sw $t6, 36($sp)
	sw $t7, 40($sp)
    sw $s0, 44($sp)
    sw $s1, 48($sp)

	lw $a2, tree
	beqz $a2, level_return   ### if(root == null)
	lw $a0, 0($a2)
	lw $a3, queue1_front
	jal insert_to_queue_start_1  ### queue1.add(root)
print_newLine00:
    move $s0, $a0
    move $s1, $v0
    la $a0, line
    li $v0, 4
    syscall
    move $a0, $s0
    move $v0, $s1
if_condition1:
	lw $t0, queue1_front
	beqz $t0, if_condition2     ### if(queue1.isEmpty())
inner_condition1:
	lw $t0, queue1_front
	bne $t0, $zero, inner_while1   ### if(!queue1.isEmpty())
	j print_newLine
inner_while1:
	lw $a3, queue1_front
	jal pop_queue_start_1    ### $a0 = pop(queue1)
	move $a0, $v0
	move $t4, $a0
	beq $a0, -10000, printX
	li $v0, 1  ### print($a0)
	syscall

	la $a0, space
	li $v0, 4
	syscall

	move $a0, $t4
	jal find  ### find queue root in the tree, address will be at $v1

	beq $v0, 1, inner_condition2

check_left_queue1:
	lw $t2, 4($v1)    ### left child adress will be at $t2
	beqz $t2, insert_x_q2_left   ### if there is no left child insert X -10,000
	lw $a0, 0($t2)        ### load value of left child
	lw $a3, queue2_front
	jal insert_to_queue_start_2

check_right_queue1:
	lw $t3, 8($v1)
	beqz $t3, insert_x_q2_right
	lw $a0, 0($t3)
	lw $a3, queue2_front
	jal insert_to_queue_start_2
    j inner_condition1
print_newLine:
	la $a0, line
	li $v0, 4
	syscall
inner_condition2:
	lw $t1, queue2_front
	bne $t1, $zero, inner_while2   ### if(!queue1.isEmpty())
	j print_newLine00
inner_while2:
	lw $a3, queue2_front
	jal pop_queue_start_2    ### $a0 = pop(queue1)
	move $a0, $v0
	move $t5, $a0
	beq $a0, -10000, printX_2
	li $v0, 1  ### print($a0)
	syscall

	la $a0, space
	li $v0, 4
	syscall
	move $a0, $t5
	jal find  ### find queue root in the tree, address will be at $v1

	beq $v0, 1, inner_condition2

check_left_tree2:
	lw $t6, 4($v1)    ### left child adress will be at $t2
	beqz $t6, insert_x_q1_left   ### if there is no left child insert X -10,000
	lw $a0, 0($t6)        ### load value of left child
	lw $a3, queue1_front
	jal insert_to_queue_start_1
check_right_tree2:
	lw $t7, 8($v1)
	beqz $t7, insert_x_q1_right
	lw $a0, 0($t7)
	lw $a3, queue1_front
	jal insert_to_queue_start_1
    j inner_condition2
level_return:
    lw $s1, 48($sp)
    lw $s0, 44($sp)
	lw $t7, 40($sp)
	lw $t6, 36($sp)
	lw $t5, 32($sp)
	lw $t4, 28($sp)
	lw $t3, 24($sp)
	lw $t2, 20($sp)
	lw $t1, 16($sp)
	lw $a3, 12($sp)
	lw $a0, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 52
	jr $ra
if_condition2:
	lw $t1, queue2_front
	beqz $t1, level_return
	j inner_condition1
insert_x_q2_left:   #### insert x to queue2 when finish go to check right queue1
	li $a0, -10000
	lw $a3, queue2_front
	jal insert_to_queue_start_2
	j check_right_queue1
insert_x_q2_right:   #### insert x to queue2 when finish go to inner condition2
	li $a0, -10000
	lw $a3, queue2_front
	jal insert_to_queue_start_2
	j inner_condition1
insert_x_q1_left:  #### insert x to 
	li $a0, -10000
	lw $a3, queue1_front
	jal insert_to_queue_start_1
	j check_right_tree2
insert_x_q1_right:  #### insert x to 
	li $a0, -10000
	lw $a3, queue1_front
	jal insert_to_queue_start_1
	j inner_condition2
printX:
	la $a0, x
	li $v0, 4
	syscall

	la $a0, space
	li $v0, 4
	syscall
	j inner_condition1
printX_2:
	la $a0, x
	li $v0, 4
	syscall

	la $a0, space
	li $v0, 4
	syscall
	j inner_condition2


######################################################
######################################################
allocate_memory:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	li $v0, 9
	li $a0, 16
	syscall
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
###########################################
#######################################

########################################################
########################################################

allocate_memory_for_queue:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	li $v0, 9
	li $a0, 8
	syscall
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
#############################################
#############################################
pop_queue_start_1:    #########FOR QUEUE1,  QUEUE HEAD POINTER AT $A3
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s3, 4($sp)
	sw $t3, 8($sp)
	sw $a3, 12($sp)
pop_body1:
	beqz $a3, pop_queue1_end2  ### if tree head is null
    lw $s3, 4($a3)
	lw $v0, 0($a3)
	sw $s3, queue1_front
    beq $s3, $zero, pop_queue1_end2_2
pop_queue_end:
	lw $a3, 12($sp)
	lw $t3, 8($sp)
	lw $s3, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
pop_queue1_end2:
	li $v0, -9999
	j pop_queue_end
pop_queue1_end2_2:	
    sw $zero, queue1_rear
    j pop_queue_end
#############################################
##############################################

#############################################
#############################################
pop_queue_start_2:    #########FOR QUEUE1,  QUEUE HEAD POINTER AT $A3
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s3, 4($sp)
	sw $t3, 8($sp)
	sw $a3, 12($sp)
pop_body1_2:
	beqz $a3, pop_queue_end2_2  ### if tree head is null
	lw $s3, 4($a3)      ### $s3 = head->next
	lw $v0, 0($a3)		### $v0 = pop(queue)
	sw $s3, queue2_front 
    beq $zero, $s3, pop_queue2_end_2_2
pop_queue_end_2:
	lw $a3, 12($sp)
	lw $t3, 8($sp)
	lw $s3, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
pop_queue_end2_2:
	li $v0, -9999
	j pop_queue_end_2
pop_queue2_end_2_2:	
    sw $zero, queue2_rear
    j pop_queue_end_2
#############################################
##############################################
insert_to_queue_start_1:     ### QUEUE head pointer AT $A3, $T4 AT NEW NODE, THE VALUE AT $A0
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $t4, 8($sp)
	sw $a3, 12($sp)
    sw $t5, 16($sp)
insert_queue_body:
	jal allocate_memory_for_queue
	move $t4, $v0     ### new allocated address at $t4
    lw $t5, queue1_rear
	beqz $t5, assign_head_queue
insert_queue_body2:
	sw $a0, 0($t4)
	sw $zero, 4($t4) 
    sw $t4, 4($t5)
	sw $t4, queue1_rear
insert_queue_return:
    lw $t5, 16($sp)
	lw $a3, 12($sp)
	lw $t4, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra
#########################################
##########################################
assign_head_queue:
    sw $t4, queue1_front
    sw $t4, queue1_rear 
	sw $a0, 0($t4)
    sw $zero, 4($t4)
	j insert_queue_return
###########################################
###########################################


#############################################
##############################################
insert_to_queue_start_2:     ### QUEUE head pointer AT $A3, $T4 AT NEW NODE, THE VALUE AT $A0
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $t4, 8($sp)
	sw $a3, 12($sp)
    sw $t5, 16($sp)
insert_queue_body_2:
	jal allocate_memory_for_queue
	move $t4, $v0   #### move address to $t4
    lw $t5, queue2_rear
	beqz $a3, assign_head_queue_2
insert_queue_body2_2:
	sw $a0, 0($t4)
	sw $zero, 4($t4)
	sw $t4, 4($t5)
    sw $t4, queue2_rear
insert_queue_return_2:
    lw $t5, 16($sp)
	lw $a3, 12($sp)
	lw $t4, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra
#########################################
##########################################
assign_head_queue_2:
    sw $t4, queue2_front
    sw $t4, queue2_rear
	sw $a0, 0($t4)
	sw $zero, 4($t4)
	j insert_queue_return_2
###########################################
###########################################