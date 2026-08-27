;; EVIL-MODE
;; ---------

;;;; I just git clone https://github.com/emacs-evil/evil into packages/evil
(add-to-list `load-path "~/.emacs.d/packages")
(add-to-list `load-path "~/.emacs.d/packages/evil")

;;;; Enable
(require `evil)
(evil-mode 1)

;;;; evil mode in minibuffer
(setq evil-want-minibuffer t)

;;;; set evil mode in some of the basic buffers
(evil-set-initial-state 'help-mode 'normal)
(evil-set-initial-state 'debugger-mode 'normal)
(evil-set-initial-state 'messages-buffer-mode 'normal)

;; EAT (TERMINAL EMULATOR)
;; -----------------------

(add-to-list 'load-path "~/.emacs.d/packages/eat")
(require 'eat)

;; CUSTOM KEYBINDS
;; ---------------

;;;; CUSTOM MINOR MODE for global keymaps
;;;; Add keymaps you want to be globally available which would override any other modes, add them to this (global-overriding-minor-mode-map)
(defvar globally-overriding-minor-mode-map (make-sparse-keymap))
(define-minor-mode globally-overriding-minor-mode 
  "A minor mode to override other keybindings."
  :global t
  :init-value nil
  :keymap globally-overriding-minor-mode-map)

;;;; OPEN init.el
(defun open-initel ()
  (interactive) ;; marking a function as interactive is necessary if it contains any user interaction (find-file does)
  (find-file "~/.emacs.d/init.el"))
(define-key globally-overriding-minor-mode-map (kbd "C-x i") 'open-initel)

;;;; SHELL COMMAND
;;;; old: (global-set-key (kbd "C-c C-s") 'shell-command)
;;;; git config --global help.format man, if you dont want the browser to open help pages as emacs runs git --help "subcommand" while
;;;; new method works in any mode that tries to steal
(define-key globally-overriding-minor-mode-map (kbd "C-c C-s") 'shell-command)

;;;; EAT SPIN/SPAWN NEW TERMINALS
(defun eat-make2 (name program &optional startfile &rest switches)
  (let ((buffer (get-buffer-create name)))
    (when (not (let ((proc (get-buffer-process buffer)))
                 (and proc (memq (process-status proc)
                                 '(run stop open listen connect)))))
      (with-current-buffer buffer
        (eat-mode)
		(pop-to-buffer-same-window buffer)
		(eat-exec buffer name program startfile switches))
    buffer)))
(defun spawn-new-eat-terminal ()
  (interactive)
  (let (input)
	(setq input (read-string "Enter terminal name: " ""))
	(let (buffer-name)
	  (if (string= input "")
		(setq buffer-name (generate-new-buffer-name "*eat*"))
		(setq buffer-name (generate-new-buffer-name (concat "*eat-" input "*"))))
	  (eat-make2 buffer-name "pwsh.exe"))))

(define-key globally-overriding-minor-mode-map (kbd "C-x t") 'spawn-new-eat-terminal)

;;;; EVIL VIM
;;;;;; Move line up
(defun move-line-up ()
  "Move the current line up."
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

;;;;;; Move line down
(defun move-line-down ()
  "Move the current line down."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

;;;;;; Bind to Ctrl+j and Ctrl+k in normal mode
(define-key evil-normal-state-map (kbd "C-j") 'move-line-down)
(define-key evil-normal-state-map (kbd "C-k") 'move-line-up)

;;;;;; Move to the first non blank character
(define-key evil-normal-state-map (kbd "H") 'evil-first-non-blank)

;;;;;; g-l to goto last line
(define-key evil-motion-state-map (kbd "g l") 'evil-jump-backward)

;;;; UI
(defun toggle-titlebar ()
  (interactive)
  (if (null (frame-parameter nil 'undecorated))
	  (set-frame-parameter nil 'undecorated t)
	(set-frame-parameter nil 'undecorated nil)))

(define-key globally-overriding-minor-mode-map (kbd "C-x u") 'toggle-titlebar)

;;;; other-window
(define-key globally-overriding-minor-mode-map (kbd "M-o") 'other-window)

;;;; delete-other-windows
(define-key globally-overriding-minor-mode-map (kbd "C-x o") 'delete-other-windows)

;;;; open dired in the home directory (real home not emacs ~)
(defun open-dired-in-home ()
  (interactive)
  (dired "~/../../"))
(define-key globally-overriding-minor-mode-map (kbd "C-x C-d") 'open-dired-in-home)

;;;; compile command
(define-key globally-overriding-minor-mode-map (kbd "C-c C-c") 'compile)

;;;; IMPORTANT !!!
;;;; Enable the global minor mode once every keymap has been added to it.
(globally-overriding-minor-mode 1)

;; CONFIG
;; ------
(setq make-backup-files nil) ;; stop creating ~ files

;; UI
;; --

;;;; CORE
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 0) ;; disable padding (otherwise you will notice a slight gap between text window and window border
(setq inhibit-startup-message t)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq ring-bell-function 'ignore) ;; disable the annoying bell sound
(setq visible-bell nil)
;;;; (set-frame-parameter nil 'undecorated t) ;; remove window title bar

;;;; FONT
;;;; (set-face-attribute 'default nil :font "JetBrains Mono" :height 120 :weight 'normal) ;; DEFAULT
(set-face-attribute 'default nil :font "Iosevka Comfy" :height 130 :weight 'normal) ;; narrower than JetBrains and looks very nice

;;;; Tabs
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)
(setq backward-delete-char-untabify-method nil)

;; CHANGE SHELL (PWSH)
;; -------------------

(let* ((pwsh-dir (expand-file-name "packages/pwsh/" user-emacs-directory))
       (pwsh-bat (expand-file-name "pwsh.bat" pwsh-dir))
       (pwsh-exe (executable-find "pwsh")))
  (when (and pwsh-exe (file-exists-p pwsh-bat))
    (setq shell-file-name pwsh-bat)
    (setq shell-command-switch "-Command")
    (setq explicit-shell-file-name pwsh-exe)
    (setq explicit-pwsh-args '("-NoProfile" "-Interactive")) ;; C-c C-s shell-command
    (setq explicit-pwsh.exe-args '("-Interactive")))) ;; M-x shell

;; MELPA PACKAGE MANAGER
;; ---------------------

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; SECONDARY PACKAGES (WITH OR WITHOUT DOWNLODING)
;; -----------------------------------------------

;;;; custom.el: to save the state in a different file
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file t)

;;;; VERTICO
;;;; vertical suggestions in M-x and other menus
(use-package vertico
  :ensure t ;; ensure that package is installed if not download and install it
  :config ;; write lisp code after this line to configure your package
  (vertico-mode 1))

;;;; MARGINALIA
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;;;; SAVEHIST
;;;; savehist for saving minibuffer history across restarts
(use-package savehist
  :ensure nil ;; since this is a default package already in emacs dont ensure it
  :config
  (savehist-mode 1))

;;;; ORDERLESS
;;;; for searching for commands without knowing the exact order
(use-package orderless
  :ensure t
  :config
  (setq completion-styles `(orderless basic))
  (setq completion-category-defaults nil))

;;;; COMPANY MODE
;;;; Provides the UI for LSP autocomplete etc...
(use-package company
  :ensure t
  :config
  (company-mode 1))
(add-hook 'after-init-hook 'global-company-mode)

;; LSP
;; ---

;; C# lsp server based on csharp-ls (https://github.com/razzmatazz/csharp-language-server)
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (csharp-mode . lsp-deferred)
  :config
  (setq lsp-csharp-server-type 'csharp-ls))

;;;; LSP-UI
;;;; The package part of lsp-mode that assists in the ui features of the lsp such as
;;;; peeks, definitions etc
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-peek-enable t)
  (setq lsp-ui-doc-enable t)
  (setq lsp-ui-doc-show-with-cursor t)
  (setq lsp-ui-doc-delay 1)
  (setq lsp-ui-doc-position 'at-point) ;; Shows at your cursor
  (setq lsp-ui-doc-max-width 60)
  (setq lsp-ui-doc-header t)
  (setq lsp-ui-doc-include-signature t))

;; THEMES
;; ------

;;;; INBUILT
;;;; (load-theme `tango-dark)
;;;; (load-theme `modus-vivendi)
;;;; EXTERNAL
;;;; EF-THEMES by Protesilaos
;;;; (use-package ef-themes
;;;;   :ensure t
;;;;   :init
;;;;   ;; This makes the Modus commands listed below consider only the Ef
;;;;   ;; themes.  For an alternative that includes Modus and all
;;;;   ;; derivative themes (like Ef), enable the
;;;;   ;; `modus-themes-include-derivatives-mode' instead.  The manual of
;;;;   ;; the Ef themes has a section that explains all the possibilities:
;;;;   ;;
;;;;   ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
;;;;   ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
;;;;   (ef-themes-take-over-modus-themes-mode 1)
;;;;   :bind
;;;;   (("<f5>" . modus-themes-rotate)
;;;;    ("C-<f5>" . modus-themes-select)
;;;;    ("M-<f5>" . modus-themes-load-random))
;;;;   :config
;;;;   ;; All customisations here.
;;;;   (setq modus-themes-mixed-fonts nil)
;;;;   (setq modus-themes-italic-constructs nil) 
;;;; 
;;;;   ;; Finally, load your theme of choice (or a random one with
;;;;   ;; `modus-themes-load-random', `modus-themes-load-random-dark',
;;;;   ;; `modus-themes-load-random-light').
;;;;   ;; (modus-themes-load-theme 'ef-cyprus)) ;; -> beautiful light theme (green)
;;;;   ;; (modus-themes-load-theme 'ef-deuteranopia-light)) ;;
;;;;   ;; (modus-themes-load-theme 'ef-dream))
;;;;   (modus-themes-load-theme 'ef-owl))

;;;; NORDIC LIGHT
;;;; (Really nice dark theme with pale sky blue accent)
(use-package nordic-night-theme
  :ensure t
  :config
  ;; Use this for the darker version
  (load-theme 'nordic-midnight t))
  ;; (load-theme 'nordic-night t))

;;;; MONO THEMES
;;;; (add-to-list 'load-path "~/.emacs.d/packages/themes/mono")
;;;; (require 'almost-mono-themes)
;;;; (almost-mono-themes--define-theme white)
;;;; (load-theme 'almost-mono-black t)
