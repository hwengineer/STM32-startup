/*
  Startup Code for Qemu-Cortex-M3

  used startup_stm32l072xx.s as prototype
*/

.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.global  g_pfnVectors
.global  Default_Handler

.word  _sidata /* start address for the initialization values of the .data section.*/
.word  _sdata  /* start address for the .data section. defined in linker script */
.word  _edata  /* end address for the .data section. defined in linker script */
.word  _sbss   /* start address for the .bss section. defined in linker script */
.word  _ebss   /* end address for the .bss section. defined in linker script */

  .section  .text.Reset_Handler
  .weak  Reset_Handler
  .type  Reset_Handler, %function
Reset_Handler:
   ldr   r0, =_estack
   mov   sp, r0          /* set stack pointer */

/* Copy the data segment initializers from flash to SRAM */
  movs  r1, #0
  b  LoopCopyDataInit

CopyDataInit:
  ldr  r3, =_sidata
  ldr  r3, [r3, r1]
  str  r3, [r0, r1]
  adds  r1, r1, #4

LoopCopyDataInit:
  ldr  r0, =_sdata
  ldr  r3, =_edata
  adds  r2, r0, r1
  cmp  r2, r3
  bcc  CopyDataInit
  ldr  r2, =_sbss
  b  LoopFillZerobss
/* Zero fill the bss segment. */
FillZerobss:
  movs  r3, #0
  str  r3, [r2]
  adds r2, r2, #4


LoopFillZerobss:
  ldr  r3, = _ebss
  cmp  r2, r3
  bcc  FillZerobss

/* Call the application's entry point.*/
  bl  main

.size  Reset_Handler, .-Reset_Handler

  .section  .text.Default_Handler,"ax",%progbits
Default_Handler:
  Infinite_Loop:
    b  Infinite_Loop
  .size  Default_Handler, .-Default_Handler

  .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object
  .size  g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  SVC_Handler
  .word  0
  .word  0
  .word  PendSV_Handler
  .word  SysTick_Handler

.weak      NMI_Handler
.thumb_set NMI_Handler,Default_Handler

.weak      HardFault_Handler
.thumb_set HardFault_Handler,Default_Handler

.weak      SVC_Handler
.thumb_set SVC_Handler,Default_Handler

.weak      PendSV_Handler
.thumb_set PendSV_Handler,Default_Handler

.weak      SysTick_Handler
.thumb_set SysTick_Handler,Default_Handler
