; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-

;; 言語設定
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;極力色付け
(global-font-lock-mode t)
;フォント変更
(set-face-attribute 'default nil
        :family "Ricty"
        :height 100)
(set-fontset-font "fontset-default"
        'japanese-jisx0208
        '("Ricty" . "jisx0208-sjis"))


;; バー表示
(when window-system
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (scroll-bar-mode 0))

;; インデントにタブ文字を使用しない
(setq-default indent-tabs-mode nil)


;スクラッチバッファを空に
(setq initial-scratch-message "")

;; load-pathを追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
             (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-path に追加
(add-to-load-path "elisp" "conf" "public_repos" "el-get")

;; package.elの設定
(when (require 'package nil t)
  ;; パッケージレポジトリにMarmaladeと開発者運営のELPAを追加
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("ELPA" . "http://tromey.com/elpa/"))
  ;; インストールしたパッケージにロードパスを通して読み込む
  (package-initialize))

;; auto-installの設定
(when (require 'auto-install nil t)
  ;; インストールディレクトリを設定する 初期値は ~/.emacs.d/auto-install
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWikiに登録されているelisp の名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup))

;; redo+の設定
(when (require 'redo+ nil t)
  ;;C-.にリドゥを割り当てる
  (global-set-key (kbd "C-.") 'redo)
)

;.jsではjs2モードにしてみる
;(autoload 'js2-mode "js2" nil t)
;(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; nXhtml
(load "nxhtml/autostart.el")

;; (setq auto-mode-alist (append (list '("\\.html\\'" . html-mumamo-mode)) auto-mode-alist))
; デフォルトだと XHTML 用になってしまうので、HTML 用にする


;; php-mode-improved
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

;;行番号の表示
(require 'linum)
(global-linum-mode t)

;; バックアップ作成なし
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq auto-save-list-file-name nil)
(setq auto-save-list-file-prefix nil)
(setq delete-auto-save-files t)

;; font size zoom
(if (and (>= emacs-major-version 23) (window-system))
    (progn
      (global-set-key
       (vector (list 'control mouse-wheel-down-event))
       'text-scale-increase)
      (global-set-key
       (vector (list 'control mouse-wheel-up-event))
       'text-scale-decrease)))

;;クリップボードの調整
(setq x-select-enable-clipboard t)

;折り返し表示ON/OFFをCtrl-c Ctrl-lに割り当て
(defun toggle-truncate-lines ()
    "折り返し表示をトグル"
    (interactive)
    (if truncate-lines
      (setq truncate-lines nil)
      (setq truncate-lines t))
    (recenter))
(define-key global-map [(C c) (C n)] 'toggle-truncate-lines)

;Ctrl-uにUndoを割り当てちゃう
(global-set-key "\C-u" 'undo)

;対応する括弧を光らせる。
(show-paren-mode t)

;全置換のキー割り当て
(define-key global-map [(C c) (C r)] 'replace-string)

;el-getの設定
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(el-get 'sync)


;elscreenで簡単にタブを移動したい
(define-key global-map [C-right] 'elscreen-next)
(define-key global-map [C-left] 'elscreen-previous)

;; anything
;; (auto-install-batch "anything")
(when (require 'anything-startup nil t)
(define-key global-map [(C c) (C v)] 'anything-for-files))

(when (require 'anything-config nil t)
  ;; root権限でアクションを実行するときのコマンド
  ;; デフォルトは"su"
  (setq anything-su-or-sudo "sudo"))

(require 'anything-match-plugin nil t)

(when (and (executable-find "cmigemo")
           (require 'migemo nil t))
  (require 'anything-migemo nil t))

(when (require 'anything-complete nil t)
  ;; lispシンボルの保管候補の再検索時間
  (anything-lisp-complete-symbol-set-timer 150))

(require 'anything-show-completion nil t)

(when (require 'auto-install nil t)
  (require 'anything-auto-install nil t))

(when (require 'descbinds-anything nil t)
  ;; describe-bindingsをAnythingに置き換える
  (descbinds-anything-install))

;; M-yにanything-show-kill-ringを割り当てる
(define-key global-map (kbd "M-y") 'anything-show-kill-ring)

;; anything-c-moccur
;; (install-elisp RET http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el)
;; 要color-moccur.el(curl)
(when (require 'anything-c-moccur nil t)
    (setq
    ;; anything-c-moccur用 `anything-idle-delay'
    anything-c-moccur-anything-idle-delay 0.1
    ;; バッファの情報をハイライトする
    lanything-c-moccur-higligt-info-line-flag t
    ;; 現在選択中の候補の位置をほかのwindowに表示する
    anything-c-moccur-enable-auto-look-flag t
    ;;起動時にポイントの位置の単語を初期パターンにする
    anything-c-moccur-enable-initial-pattern t)
    ;; C-M-oにanything-c-moccur-occur-by-moccurを割り当てる
  (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur))

;; color-moccurの設定
(when (require 'color-moccur nil t)
  ;; M-oにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りでAND検索
(setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  ;; Migemoを利用できる環境であればMigemoを使う
  (when (and (executable-find "cmigemo")
        (require 'migemo nil t))
    (setq moccur-use-migemo t)))

;; moccur-editの設定
(require 'moccur-edit nil t)
;; moccur-edit-finish-editと同時にファイルを保存する
(defadvice moccur-edit-change-file
  (after save-after-moccur-edit-buffer activate)
  (save-buffer))

;; wgrepの設定
(require 'wgrep nil t)

;; undo-histの設定
(when (require 'undohist nil t)
  (undohist-initialize))

;; undo-treeの設定
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))

;; point-undoの設定
(when (require 'point-undo nil t)
  (define-key global-map (kbd "M-[") 'point-undo)
  (define-key global-map (kbd "M-]") 'point-redo)
)
;; 起動画面の消去
(setq inhibit-startup-message t)

;オートコンプリート
(when (require 'auto-complete-config nil t)
  (global-auto-complete-mode t)
  (add-to-list 'ac-dictionary-directories
               "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default))

;Rubyモードでオムニ補完を
(require 'auto-complete-ruby)

;Rubyのendに対応するのを光らせてくれたりうんたらかんたら
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle 'overlay)

;; 行末の空白を強調表示
(setq-default show-trailing-whitespace t)
(set-face-background 'trailing-whitespace "#b14770")

(defvar html-helper-new-buffer-template
  '("<!DOCTYPE html>\n"
    "<html lang=\"ja\">\n"
    "<head>\n"
    "<meta charset=\"UTF-8\">\n"
    "<title>""</title>\n"
    "<link rel=\"stylesheet\" type=\"text/css\" href=\".css\">\n"
    "</head>\n"
    "<body>\n\n<h1>""</h1>\n\n"
    "\n</body>\n</html>\n")
  "*Template for new buffers, inserted by html-helper-insert-new-buffer-strings if
html-helper-build-new-buffer is set to t")

;; smart-kill-line
(defun smart-kill-line ()
  "Kill line include the newline if currently at beginning of line. Otherwise kill-line."
  (interactive "^")
  (if (= (line-beginning-position) (point))
      (kill-whole-line)
    (kill-line)))
(define-key global-map [(C k)] 'smart-kill-line)

;;ElScrean
;;ElScreanのプレフィックスキーを変更する (初期値はC-z)
;;(setq elscreen-prefix-key (kbd "C-t"))
(when (require 'elscreen nil t)
  (if window-system
    (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-map (kbd "C-z") 'suspend-emacs)))


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(font-lock-warning-face ((((class color) (min-colors 88) (background light)) (:foreground "peru"))))
 '(html-helper-bold-face ((((class color) (background light)) (:foreground "peru" :weight normal))))
 '(html-tag-face ((((class color) (background light)) (:foreground "dodger blue" :weight normal)))))




