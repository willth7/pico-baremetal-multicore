;   Copyright 2022 Will Thomas
;
;   Licensed under the Apache License, Version 2.0 (the "License");
;   you may not use this file except in compliance with the License.
;   You may obtain a copy of the License at
;
;       http:;www.apache.org/licenses/LICENSE-2.0;
;
;   Unless required by applicable law or agreed to in writing, software
;   distributed under the License is distributed on an "AS IS" BASIS,
;   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;   See the License for the specific language governing permissions and
;   limitations under the License.

	ldr r0, *sp
	mov sp, r0
	
	ldr r0, *sio_base
	ldr r1, r0, 0
	cmp r1, 1
	beq *led
	
*core
	bl *fifo_drain
	mov r1, 0
	bl *fifo_writ
	bl *fifo_read
	cmp r1, 0
	bne *core
	
	bl *fifo_drain
	mov r1, 0
	bl *fifo_writ
	bl *fifo_read
	cmp r1, 0
	bne *core
	
	mov r1, 1
	bl *fifo_writ
	bl *fifo_read
	cmp r1, 1
	bne *core
	
	ldr r4, *sram_base
	mov r1, r4
	bl *fifo_writ
	bl *fifo_read
	cmp r1, r4
	bne *core
	
	mov r1, sp
	bl *fifo_writ
	bl *fifo_read
	cmp r1, sp
	bne *core
	
	add r4, 1
	mov r1, r4
	bl *fifo_writ
	bl *fifo_read
	cmp r1, r4
	bne *core
	
	b *loop
	
*fifo_drain
	ldr r0, *sio_base
	ldr r1, r0, 22
	ldr r1, r0, 20
	
	mov r2, 1
	and r1, r2
	bne *fifo_drain
	sev
	bx lr

*fifo_writ
	ldr r0, *sio_base
	ldr r3, r0, 20
	mov r2, 2
	and r3, r2
	beq *fifo_writ
	
	str r1, r0, 21
	sev
	bx lr
	
*fifo_read
	ldr r0, *sio_base
	ldr r3, r0, 20
	mov r2, 1
	and r3, r2
	beq *wfe
	
	ldr r1, r0, 22
	bx lr

*wfe
	wfe
	b *fifo_read
	
*led
	ldr r0, *rst_clr
	mov r1, 32
	str r1, r0, 0
	
*rst
	ldr r0, *rst_base
	ldr r1, r0, 2
	cmp r1, 0
	beq *rst
	
	ldr r0, *ctrl
	mov r1, 5
	str r1, r0, 0
	
	mov r1, 1
	lsl r1, r1, 25
	
	ldr r0, *sio_base
	str r1, r0, 9
	str r1, r0, 5
	
*loop
	b *loop

*rst_base
	~byt4 0x4000c000
	
*rst_clr
	~byt4 0x4000f000
	
*ctrl
	~byt4 0x400140cc
	
*sio_base
	~byt4 0xd0000000
	
*sram_base
	~byt4 0x20000000
	
*sp
	~byt4 0x20001000
