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
		; メッセージを表示して再起動
		;-----------------------------------
		cdecl	puts, data.s0				; puts(data.s0)

		;-----------------------------------
		; キー入力待ち
		;-----------------------------------
wait_key:
		mov		ah, 0x10					; // キー入力待ち
		int		0x16						; AL = BIOS(0x16, 0x10);

		cmp		al, ' '						; ZF = AL == ' ';
		jne		wait_key

		cdecl	puts, data.s1				; // 改行
		int		0x19						; BIOS(0x19)	// reboot();

		;---------------------------------------
		; 終了
		;---------------------------------------
		jmp		$							; while (1) ; // 無限ループ

		;-----------------------------------
		; データ
		;-----------------------------------
data:
.s0		db	0x0A, 0x0D, "Push SPACE key to reboot...", 0x0A, 0x0D, 0
.s1		db	0x0A, 0x0D, 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:										; ブートドライブに関する情報
.DRIVE:			dw 0						; ドライブ番号

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/real/puts.s"

;************************************************************************
;	ブートフラグ（先頭512バイトの終了）
;************************************************************************
		times	510 - ($ - $$) db 0x00
		db	0x55, 0xAA
