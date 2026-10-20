;; ---- Basic UI & Editing ----
(setq standard-indent 2)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-message t)
(global-display-line-numbers-mode 1)
(setq-default indent-tabs-mode nil)
(setq require-final-newline t)
(setq-default fill-column 79)
(global-auto-revert-mode t)

;; Move between Emacs tiles using C-x and Arrow Keys
(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)

(define-key global-map "\C-l" 'goto-line)
(define-key global-map "\M-/" 'hippie-expand)
(define-key global-map "\C-t" 'comment-or-uncomment-region)

(defun shift-text (distance)
  (if (use-region-p)
      (let ((mark (mark)))
        (save-excursion
          (indent-rigidly (region-beginning) (region-end) distance)
          (push-mark mark t t)
          (setq deactivate-mark nil)))
    (indent-rigidly (line-beginning-position) (line-end-position) distance)))

(add-hook 'before-save-hook 'my-prog-nuke-trailing-whitespace)
(defun my-prog-nuke-trailing-whitespace ()
  (when (derived-mode-p 'prog-mode)
    (delete-trailing-whitespace)))


;; ---- Theming (DOOM) ----
(require 'doom-themes)
(require 'doom-modeline)

;; 1. Set all your preferences first (safe to do without a GUI)
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t
      doom-modeline-height 35
      doom-modeline-icon t)

;; 2. Create a function to apply the theme and visual tweaks
(defun my-apply-doom-theme ()
  (load-theme 'doom-one t)
  (doom-modeline-mode 1)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; 3. Load correctly whether running as a daemon or standalone
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my-apply-doom-theme)
  (my-apply-doom-theme))


;; ---- Completion (Vertico) ----
(vertico-mode 1)
(marginalia-mode 1)
(setq completion-styles '(orderless basic))

;; ---- Programming Modes ----
(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)
(setq auto-mode-alist (cons '("\\.md" . markdown-mode) auto-mode-alist))

(require 'python-mode)
(require 'haskell-mode)
(require 'git-commit)
(add-hook 'python-mode 'rainbow-identifiers-mode)

;; ---- Quarto / Polymode ----
(use-package polymode :ensure t)
(use-package poly-markdown :ensure t :after polymode)
(use-package poly-R :ensure t :after polymode)
(use-package poly-markdown
  :ensure t
  :mode (("\\.qmd\\'" . poly-markdown-mode)))

;; ---- File Management ----
(recentf-mode 1)
(setq recentf-max-saved-items 100)
(global-set-key (kbd "C-c r") 'recentf-open-files)

(setq ispell-program-name "aspell")
(setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))

;; ---- Treemacs ----
;; (add-hook 'emacs-startup-hook #'treemacs)
;; (add-hook 'server-after-make-frame-hook #'treemacs)
(with-eval-after-load 'treemacs
  (treemacs-follow-mode t)
  (treemacs-project-follow-mode t))

;; ---- Gemini / AI ----
(use-package gptel
  :ensure t
  :config
  (setq gptel-default-mode 'org-mode)
  (setq gptel-model "gemini-2.5-pro"
        gptel-backend
        (gptel-make-gemini "Gemini"
          :key (gptel-api-key-from-auth-source "gemini.google.com")
          :stream t
          :models '("gemini-2.5-pro" "gemini-3-flash" "gemini-2.0-flash" "gemini-2.5-flash"))))

(global-set-key (kbd "C-c g c") 'gptel)
(global-set-key (kbd "C-c g s") 'gptel-send)
(global-set-key (kbd "C-c g m") 'gptel-menu)

;; ---- Web Browser Integration ----
;; Tell Emacs to use the system default browser for opening links and UI
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "xdg-open")

;; Ensure GUI Emacs can see Nix binaries
(setenv "PATH" (concat (getenv "PATH") ":" (expand-file-name "~/.nix-profile/bin")))
(add-to-list 'exec-path (expand-file-name "~/.nix-profile/bin"))

(set-face-attribute 'default nil :font "FiraCode Nerd Font")

;; Completely disable all startup and splash screens
(setq inhibit-startup-screen t)

;; Force the Emacs bootloader to focus strictly on the Agenda buffer
(setq initial-buffer-choice
      (lambda ()
        (org-agenda nil "a")
        (delete-other-windows)
        (get-buffer "*Org Agenda*")))

;; Ensure Dired uses the icons
(add-hook 'dired-mode-hook #'nerd-icons-dired-mode)

;; Optional: If you want icons in your Vertico completion menus too
;; (requires adding 'nerd-icons-completion' to your Nix packages)
(nerd-icons-completion-mode 1)

;; Disable legacy UI chrome
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

;; Add breathing room inside the Emacs window (adjust 15 to your liking)
(modify-all-frames-parameters
 '((right-divider-width . 1)
   (bottom-divider-width . 1)
   (internal-border-width . 15)))

;; Enable vertical completion menus
(vertico-mode 1)

;; Optional Vertico tweaks for a better feel
(setq vertico-cycle t)      ; Enable wrapping around the list
(setq vertico-resize nil)   ; Keep the menu a fixed height

;; Enable rich annotations (docstrings, file dates) next to the items
(marginalia-mode 1)

;; ---- Terminal (Vterm) ----
(use-package vterm
  :ensure t
  :config
  ;; Increase the scrollback buffer for long data assimilation logs
  (setq vterm-max-scrollback 10000)

  ;; Automatically kill the Emacs buffer when you type 'exit'
  (setq vterm-kill-buffer-on-exit t))

;; Turn off line numbers in the terminal
(add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode -1)))

;; Bind a quick shortcut to launch it
(global-set-key (kbd "C-c v") 'multi-vterm)

;; ---- Jujutsu (vc-jj) Integration ----
(use-package vc-jj
  :config
  (add-to-list 'vc-handled-backends 'jj))

;; ---- TRAMP (Remote Editing) ----
(require 'tramp)
;; Force SSH as the default method for speed and compatibility
(setq tramp-default-method "ssh")
;; Disable version control checks on remote files to prevent massive lag
(setq vc-ignore-dir-regexp (format "%s\\|%s" vc-ignore-dir-regexp tramp-file-name-regexp))

;; --- EGLOT & GRAMMAR CHECKING ---
(with-eval-after-load 'eglot
  ;; Map ltex-ls-plus to LaTeX, TeX, and Org modes
  (add-to-list 'eglot-server-programs
               '((latex-mode tex-mode org-mode) . ("ltex-ls-plus")))

  ;; Tell LTeX you are writing in US English (change if needed)
  (setq-default eglot-workspace-configuration
                '((ltex . ((language . "en-US"))))))

;; Automatically start the grammar checker in these modes
;; (add-hook 'org-mode-hook 'eglot-ensure)
(add-hook 'latex-mode-hook 'eglot-ensure)
(add-hook 'tex-mode-hook 'eglot-ensure)

(use-package consult-gh
  :ensure t)

;; Only start Eglot in real file buffers, never in org-capture indirect buffers
(add-hook 'org-mode-hook
          (lambda ()
            (unless (buffer-base-buffer)
              (eglot-ensure))))

;; Prevent Emacs 30 track-changes assertion from aborting org-capture-finalize
(with-eval-after-load 'track-changes
  (advice-add 'track-changes--before :around
              (lambda (orig-fun &rest args)
                (condition-case nil
                    (apply orig-fun args)
                  (cl-assertion-failed nil)))))
