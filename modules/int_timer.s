;************************************************************************
;	例外:タイマー
;************************************************************************
int_timer:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
        pusha
        push    ds
        push    es

		;---------------------------------------
		; データ用セグメントの設定
		;---------------------------------------
        mov     ax, 0x0010                      ;
        mov     ds, ax                          ;
        mov     es, ax                          ;

		;---------------------------------------
		; TICK
		;---------------------------------------
        inc     dword [TIMER_COUNT]             ; TIMER_COUNT++; // 割り込み回数の更新

		;---------------------------------------
		; 割り込みフラグをクリア(EOI)
		;---------------------------------------
        outp    0x20, 0x20                      ; // マスタPIC:EOIコマンド

		;---------------------------------------
		; タスクの切り替え
		;---------------------------------------
		str		ax								; AX = TR; // 現在のタスクレジスタ
		cmp		ax, SS_TASK_0					; switch (AX)
		je		.11L							; {
		cmp		ax, SS_TASK_1					;
		je		.12L							;
		cmp		ax, SS_TASK_2					;
		je		.13L							;
		cmp		ax, SS_TASK_3					;
		je		.14L							;
		cmp		ax, SS_TASK_4					;
		je		.15L							;
		cmp		ax, SS_TASK_5					;
		je		.16L							;
												;   default:
		jmp		SS_TASK_0:0						;     // タスク0に切り替え
		jmp		.10E							;     break;
												;
.11L:											;   case SS_TASK_0:
		jmp		SS_TASK_1:0						;     // タスク1に切り替え
		jmp		.10E							;     break;
												;
.12L:											;   case SS_TASK_1:
		jmp		SS_TASK_2:0						;     // タスク2に切り替え
		jmp		.10E							;     break;
												;
.13L:											;   case SS_TASK_2:
		jmp		SS_TASK_3:0						;     // タスク3に切り替え
		jmp		.10E							;     break;
												;
.14L:											;   case SS_TASK_3:
		jmp		SS_TASK_4:0						;     // タスク4に切り替え
		jmp		.10E							;     break;
												;
.15L:											;   case SS_TASK_4:
		jmp		SS_TASK_5:0						;     // タスク5に切り替え
		jmp		.10E							;     break;
												;
.16L:											;   case SS_TASK_5:
		jmp		SS_TASK_6:0						;     // タスク6に切り替え
		jmp		.10E							;     break;
.10E:											; }

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
        pop     es                              ;
        pop     ds                              ;
        popa

        iret

ALIGN 4, db 0
TIMER_COUNT:    dd  0

