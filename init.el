;; EVIL-MODE
;;;; I just git clone https://github.com/emacs-evil/evil into packages/evil
(add-to-list `load-path "~/.emacs.d/packages")
(add-to-list `load-path "~/.emacs.d/packages/evil")
;;;; Enable
(require `evil)
(evil-mode 1)
;;;; evil mode in minibuffer
(setq evil-want-minibuffer t)

;; CUSTOM KEYBINDS
;;;; SHELL COMMAND
;;;; old: (global-set-key (kbd "C-c C-s") 'shell-command)
;;;; new method works in any mode that tries to steal
(defvar shell-minor-mode-map (make-sparse-keymap))
(define-key shell-minor-mode-map (kbd "C-c C-s") 'shell-command)
(define-minor-mode shell-minor-mode 
  "A minor mode to override other keybindings."
  t " shell-minor-mode" 'shell-minor-mode-map)
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

;; UI
;;;; CORE
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 0) ;; disable padding (otherwise you will notice a slight gap between text window and window border
(setq inhibit-startup-message t)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq ring-bell-function `ignore) ;; disable the annoying bell sound
(setq visible-bell nil)
(set-frame-parameter nil 'undecorated t) ;; remove window title bar
;;;; FONT
(set-face-attribute 'default nil :font "JetBrains Mono" :height 140)
;;;; Tabs
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)
(setq backward-delete-char-untabify-method nil)

;; CHANGE SHELL (PWSH)
(let* ((pwsh-dir (expand-file-name "packages/pwsh/" user-emacs-directory))
       (pwsh-bat (expand-file-name "pwsh.bat" pwsh-dir))
       (pwsh-exe (executable-find "pwsh")))
  
  (when (and pwsh-exe (file-exists-p pwsh-bat))
    (setq shell-file-name pwsh-bat)
    (setq shell-command-switch "-Command")
    (setq explicit-shell-file-name pwsh-exe)
    (setq explicit-pwsh-args '("-NoProfile" "-Interactive"))
    (setq explicit-pwsh.exe-args '("-NoProfile" "-Interactive"))))

;; PACKAGES (WITH OR WITHOUT DOWNLODING)
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

;; MELPA PACKAGE MANAGER
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; LSP
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
;;;; INBUILT
;;;; (load-theme `tango-dark)
;;;; (load-theme `modus-vivendi)
;;;; EXTERNAL
;;;; EF-THEMES by Protesilaos
(use-package ef-themes
  :ensure t
  :init
  ;; This makes the Modus commands listed below consider only the Ef
  ;; themes.  For an alternative that includes Modus and all
  ;; derivative themes (like Ef), enable the
  ;; `modus-themes-include-derivatives-mode' instead.  The manual of
  ;; the Ef themes has a section that explains all the possibilities:
  ;;
  ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
  ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
  (ef-themes-take-over-modus-themes-mode 1)
  :bind
  (("<f5>" . modus-themes-rotate)
   ("C-<f5>" . modus-themes-select)
   ("M-<f5>" . modus-themes-load-random))
  :config
  ;; All customisations here.
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)

  ;; Finally, load your theme of choice (or a random one with
  ;; `modus-themes-load-random', `modus-themes-load-random-dark',
  ;; `modus-themes-load-random-light').
  ;; (modus-themes-load-theme 'ef-cyprus)) ;; -> beautiful light theme (green)
  (modus-themes-load-theme 'ef-dark))
