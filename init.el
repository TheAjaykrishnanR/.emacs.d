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
(global-set-key (kbd "C-c C-c") 'shell-command)
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

;; THEMES
(load-theme `tango-dark)
;;(load-theme `modus-vivendi) 

;; PACKAGES (WITH OR WITHOUT DOWNLODING)
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
  (setq completion-styles `(orderless basic))) 

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(marginalia orderless vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
