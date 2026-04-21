	.section .text
	.align 2

	.globl aes32esmi_bs0
	.type  aes32esmi_bs0, @function
aes32esmi_bs0:
	aes32esmi a0, a0, a1, 0
	ret

	.globl aes32esmi_bs1
	.type  aes32esmi_bs1, @function
aes32esmi_bs1:
	aes32esmi a0, a0, a1, 1
	ret

	.globl aes32esmi_bs2
	.type  aes32esmi_bs2, @function
aes32esmi_bs2:
	aes32esmi a0, a0, a1, 2
	ret

	.globl aes32esmi_bs3
	.type  aes32esmi_bs3, @function
aes32esmi_bs3:
	aes32esmi a0, a0, a1, 3
	ret

	.globl aes32esi_bs0
	.type  aes32esi_bs0, @function
aes32esi_bs0:
	aes32esi a0, a0, a1, 0
	ret

	.globl aes32esi_bs1
	.type  aes32esi_bs1, @function
aes32esi_bs1:
	aes32esi a0, a0, a1, 1
	ret

	.globl aes32esi_bs2
	.type  aes32esi_bs2, @function
aes32esi_bs2:
	aes32esi a0, a0, a1, 2
	ret

	.globl aes32esi_bs3
	.type  aes32esi_bs3, @function
aes32esi_bs3:
	aes32esi a0, a0, a1, 3
	ret