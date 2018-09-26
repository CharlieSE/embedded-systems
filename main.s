;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 2/4/2017
; Last Modified: 8/24/2018
; Brief description of the program
;   The LED toggles at 2 Hz and a varying duty-cycle
; Hardware connections (External: One button and one LED)
;  PE2 is Button input  (1 means pressed, 0 means not pressed)
;  PE3 is LED output (1 activates external LED on protoboard)
;  PF4 is builtin button SW1 on Launchpad (Internal) 
;        Negative Logic (0 means pressed, 1 means not pressed)
; Overall functionality of this system is to operate like this
;   1) Make PE3 an output and make PE2 and PF4 inputs.
;   2) The system starts with the the LED toggling at 2Hz,
;      which is 2 times per second with a duty-cycle of 30%.
;      Therefore, the LED is ON for 150ms and off for 350 ms.
;   3) When the button (PE2) is pressed-and-released increase
;      the duty cycle by 20% (modulo 100%). Therefore for each
;      press-and-release the duty cycle changes from 30% to 70% to 70%
;      to 90% to 10% to 30% so on
;   4) Implement a "breathing LED" when SW1 (PF4) on the Launchpad is pressed:
;      a) Be creative and play around with what "breathing" means.
;         An example of "breathing" is most computers power LED in sleep mode
;         (e.g., https://www.youtube.com/watch?v=ZT6siXyIjvQ).
;      b) When (PF4) is released while in breathing mode, resume blinking at 2Hz.
;         The duty cycle can either match the most recent duty-
;         cycle or reset to 30%.
;      TIP: debugging the breathing LED algorithm using the real board.
; PortE device registers
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_DEN_R   EQU 0x4002451C
; PortF device registers
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

DUTY_10	EQU	0x000F0886	;ON for 50ms
DUTY_30	EQU	0x002D1991	;ON for 150ms
DUTY_50	EQU	0x004B2A9C	;ON for 250ms
DUTY_70	EQU	0x00693BA8	;ON for 350ms
DUTY_90	EQU	0x00874CB3	;ON for 450ms

       IMPORT  TExaS_Init
       THUMB
       AREA    DATA, ALIGN=2
;global variables go here


       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
 ; TExaS_Init sets bus clock at 80 MHz
    BL  TExaS_Init ; voltmeter, scope on PD3
 ; Initialization goes here
	
	LDR R1, =SYSCTL_RCGCGPIO_R ;clock
	LDR R0, [R1]
	ORR R0, R0, #0x30 	;setting bit 4 for port E
	STR R0, [R1] 		;storing to clock
	NOP 				;delay for clock
	NOP
	
	LDR R1, =GPIO_PORTE_DIR_R
	BIC R0, #0X0C 
	ORR R0, #0X08 ;0 input 1 output pe3 output 
	STR R0, [R1]
	
	LDR R1, =GPIO_PORTE_DEN_R
	BIC R0, #0x0C
	ORR R0, #0X0C 
	STR R0, [R1]
 
    CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
loop  
; main engine goes here

		
		
next	LDR R0, =DUTY_30	;First argument for delay function, # of ms
		BL 	Delay
		BL Toggle
		AND R2, R1, #0x04
		CMP R2, #0
		BEQ next
		BL Loop1
	
		
next1	LDR R0, =DUTY_50	;First argument for delay function, # of ms
		BL 	Delay
		BL Toggle
		AND R2, R1, #0x04
		CMP R2, #0x00
		BEQ next1
		BL Loop1
		
next2 	LDR R0, =DUTY_70	;First argument for delay function, # of ms
		BL 	Delay
		BL Toggle
		AND R2, R1, #0x04
		CMP R2, #0
		BEQ next2
		BL Loop1
   
next3 	LDR R0, =DUTY_90	;First argument for delay function, # of ms
		BL 	Delay
		BL Toggle
		AND R2, R1, #0x04
		CMP R2, #0
		BEQ next3
		BL Loop1
		
next4	LDR R0, =DUTY_10	;First argument for delay function, # of ms
		BL 	Delay
		BL Toggle
		AND R2, R1, #0x04
		CMP R2, #0
		BEQ next4
		BL Loop1		
   
    B   loop
      
Delay
wait SUBS R0, R0, #1
	 BNE  wait
	 BX	  LR
Toggle
	LDR	R0, =GPIO_PORTE_DATA_R	;Toggle LED at PE3
	LDR R1, [R0]
	EOR R1, #0x08
	STR	R1, [R0]
	BX LR		
Loop1 	
	LDR	R0, =GPIO_PORTE_DATA_R	;Toggle LED at PE3
	LDR R1, [R0]
	AND R2, R1, #0x04
	CMP R2, #0
	BNE Loop1
	BX LR
	
     ALIGN      ; make sure the end of this section is aligned
     END        ; end of file

