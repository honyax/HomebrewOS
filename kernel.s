;************************************************************************
;	HomebrewOS kernelプログラム
;************************************************************************
;************************************************************************
;	マクロ
;************************************************************************
%include	"../include/define.s"
%include	"../include/macro.s"

		ORG		KERNEL_LOAD				    	; kernelのロードアドレスをアセンブラに指示

[BITS 32]
;************************************************************************
;	エントリポイント
;************************************************************************
kernel:
		;---------------------------------------
		; フォントアドレスを取得
		;---------------------------------------
		mov		esi, BOOT_LOAD + SECT_SIZE		; ESI   = 0x7C00 + 512
		movzx	eax, word [esi + 0]				; EAX   = [ESI + 0] // セグメント
		movzx	ebx, word [esi + 2]				; EBX   = [ESI + 2] // オフセット
		shl		eax, 4							; EAX <<= 4;
		add		eax, ebx						; EAX  += EBX;
		mov		[FONT_ADR], eax					; FONT_ADR[0] = EAX;

		;---------------------------------------
		; 初期化
		;---------------------------------------
		cdecl	init_int						; // 割り込みベクタの初期化

		set_vect	0x00, int_zero_div			; // 割り込み処理の登録：0除算

		;---------------------------------------
		; 文字の表示
		;---------------------------------------
		;cdecl	draw_char, 0, 0, 0x010F, 'A'
		;cdecl	draw_char, 1, 0, 0x010F, 'B'
		;cdecl	draw_char, 2, 0, 0x010F, 'C'

		;cdecl	draw_char, 0, 0, 0x0402, '0'
		;cdecl	draw_char, 1, 0, 0x0212, '1'
		;cdecl	draw_char, 2, 0, 0x0212, '_'

		;---------------------------------------
		; 線を描画
		;---------------------------------------
		;cdecl	draw_line, 100, 100,   0,   0, 0x0F
		;cdecl	draw_line, 100, 100, 200,   0, 0x0F
		;cdecl	draw_line, 100, 100, 200, 200, 0x0F
		;cdecl	draw_line, 100, 100,   0, 200, 0x0F

		;cdecl	draw_line, 100, 100,  50,   0, 0x02
		;cdecl	draw_line, 100, 100, 150,   0, 0x03
		;cdecl	draw_line, 100, 100, 150, 200, 0x04
		;cdecl	draw_line, 100, 100,  50, 200, 0x05

		;cdecl	draw_line, 100, 100,   0,  50, 0x02
		;cdecl	draw_line, 100, 100, 200,  50, 0x03
		;cdecl	draw_line, 100, 100, 200, 150, 0x04
		;cdecl	draw_line, 100, 100,   0, 150, 0x05

		;cdecl	draw_line, 100, 100, 100,   0, 0x0F
		;cdecl	draw_line, 100, 100, 200, 100, 0x0F
		;cdecl	draw_line, 100, 100, 100, 200, 0x0F
		;cdecl	draw_line, 100, 100,   0, 100, 0x0F

		;---------------------------------------
		; 矩形を描画
		;---------------------------------------
		;cdecl	draw_rect, 100, 100, 200, 200, 0x03
		;cdecl	draw_rect, 400, 250, 150, 150, 0x05
		;cdecl	draw_rect, 350, 400, 300, 100, 0x06

		;---------------------------------------
		; フォントの一覧表示
		;---------------------------------------
		cdecl	draw_font, 63, 13				; // フォントの一覧表示
		cdecl	draw_color_bar, 63, 4			; // カラーバーの表示

		;---------------------------------------
		; 文字列の表示
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x010F, .s0	; draw_str();

		;---------------------------------------
		; 0除算による割り込みを呼び出し
		;---------------------------------------
;		int		0								; // 割り込み処理の呼び出し

		;---------------------------------------
		; 0除算による割り込みを生成
		;---------------------------------------
		mov		al, 0							; AL = 0;
		div		al								; ** 0除算 **

		;---------------------------------------
		; 時刻の表示
		;---------------------------------------
.10L:											; do
												; {
		cdecl	rtc_get_time, RTC_TIME			;   EAX = get_time(&RTC_TIME);
		cdecl	draw_time, 72, 0, 0x0700, dword [RTC_TIME]
		jmp		.10L							; } while (1);

		;---------------------------------------
		; 処理の終了
		;---------------------------------------
		jmp		$								; while (1); // 無限ループ

.s0:	db	" Hello, honyax kernel! ", 0

ALIGN 4, db 0
FONT_ADR:	dd	0
RTC_TIME:	dd	0

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/rtc.s"
%include	"../modules/protect/draw_time.s"
%include	"modules/interrupt.s"

;************************************************************************
;	パディング
;************************************************************************
		times	KERNEL_SIZE - ($ - $$)	db	0	; パディング
