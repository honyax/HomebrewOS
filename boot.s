;************************************************************************
;	HomebrewOS ブートプログラム
;************************************************************************
		BOOT_LOAD	equ		0x7C00			; ブートプログラムのロード位置
		ORG		BOOT_LOAD					; ロードアドレスをアセンブラに指示

;************************************************************************
;	マクロ
;************************************************************************
%include	"../include/macro.s"

;************************************************************************
;	エントリポイント
;************************************************************************
entry:
		;-----------------------------------
		; BPB(BIOS Parameter Block)
		;-----------------------------------
		jmp		ipl							; iplへジャンプ
		times	90 - ($ - $$) db 0x90		; 90の位置まで0x90(NOP)で埋める

		;-----------------------------------
		; IPL(Initial Program Loader)
		;-----------------------------------
ipl:
		cli									; 割り込み禁止

		mov		ax, 0x0000					; AX = 0x0000
		mov		ds, ax						; DS = 0x0000
		mov		es, ax						; ES = 0x0000
		mov		ss, ax						; SS = 0x0000
		mov		sp, BOOT_LOAD				; SP = 0x7C00

		sti									; 割り込み許可

		mov		[BOOT.DRIVE], dl			; ブートドライブを保存

		;-----------------------------------
		; 文字を表示
		;-----------------------------------
		cdecl	puts, data.s0				; puts(data.s0);

		;---------------------------------------
		; 数値を表示
		;---------------------------------------
		cdecl	itoa,  8086, data.s1, 8, 10, 0b0001	; "    8086"
		cdecl	puts, data.s1

		cdecl	itoa,  8086, data.s1, 8, 10, 0b0011	; "+   8086"
		cdecl	puts, data.s1

		cdecl	itoa, -8086, data.s1, 8, 10, 0b0001	; "-   8086"
		cdecl	puts, data.s1

		cdecl	itoa,    -1, data.s1, 8, 10, 0b0001	; "-      1"
		cdecl	puts, data.s1

		cdecl	itoa,    -1, data.s1, 8, 10, 0b0000	; "   65535"
		cdecl	puts, data.s1

		cdecl	itoa,    -1, data.s1, 8, 16, 0b0000	; "    FFFF"
		cdecl	puts, data.s1

		cdecl	itoa,    12, data.s1, 8,  2, 0b0100	; "00001100"
		cdecl	puts, data.s1

		;---------------------------------------
		; 終了
		;---------------------------------------
		jmp		$							; while (1) ; // 無限ループ

		;-----------------------------------
		; データ
		;-----------------------------------
data:
.s0		db	"HomebrewOS Booting...", 0x0A, 0x0D, 0
.s1		db	"--------", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:										; ブートドライブに関する情報
.DRIVE:			dw 0						; ドライブ番号

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/real/puts.s"
%include	"../modules/real/itoa.s"

;************************************************************************
;	ブートフラグ（先頭512バイトの終了）
;************************************************************************
		times	510 - ($ - $$) db 0x00
		db	0x55, 0xAA
