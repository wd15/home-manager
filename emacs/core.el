;; ---- Basic UI & Editing ----
(setq standard-indent 2
      inhibit-startup-screen t
      require-final-newline t)
(setq-default indent-tabs-mode nil
              fill-column 79)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(global-display-line-numbers-mode 1)
(global-auto-revert-mode t)

;; Frame geometry and daemon-safe font configuration
(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font"))
(modify-all-frames-parameters
 '((right-divider-width . 1)
   (bottom-divider-width . 1)
   (internal-border-width . 15)))

;; Move between Emacs tiles using C-x and Arrow Keys
(global-set-key (kbd "C-x <left>")  #'windmove-left)
(global-set-key (kbd "C-x <right>") #'windmove-right)
(global-set-key (kbd "C-x <up>")    #'windmove-up)
(global-set-key (kbd "C-x <down>")  #'windmove-down)

(define-key global-map "\C-l" #'goto-line)
(define-key global-map "\M-/" #'hippie-expand)
(define-key global-map "\C-t" #'comment-or-uncomment-region)

(defun shift-text (distance)
  (if (use-region-p)
      (let ((mark (mark)))
        (save-excursion
          (indent-rigidly (region-beginning) (region-end) distance)
          (push-mark mark t t)
          (setq deactivate-mark nil)))
    (indent-rigidly (line-beginning-position) (line-end-position) distance)))

(defun my-prog-nuke-trailing-whitespace ()
  (when (derived-mode-p 'prog-mode)
    (delete-trailing-whitespace)))
(add-hook 'before-save-hook #'my-prog-nuke-trailing-whitespace)

;; ---- Theming (DOOM) ----
(require 'doom-themes)
(require 'doom-modeline)

(setq doom-themes-enable-bold t
      doom-themes-enable-italic t
      doom-modeline-height 35
      doom-modeline-icon t)

(defun my-apply-doom-theme ()
  (load-theme 'doom-one t)
  (doom-modeline-mode 1)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my-apply-doom-theme)
  (my-apply-doom-theme))

;; ---- Completion (Vertico & Marginalia) ----
(use-package vertico
  :init
  (vertico-mode 1)
  :config
  (setq vertico-cycle t
        vertico-resize nil))

(setq completion-styles '(orderless basic))
(marginalia-mode 1)
(nerd-icons-completion-mode 1)
(add-hook 'dired-mode-hook #'nerd-icons-dired-mode)

;; ---- Programming Modes ----
(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(require 'python-mode)
(require 'haskell-mode)
(require 'git-commit)
(add-hook 'python-mode-hook #'rainbow-identifiers-mode)

;; ---- Quarto / Polymode ----
(use-package polymode :ensure t)
(use-package poly-R :ensure t :after polymode)
(use-package poly-markdown
  :ensure t
  :after polymode
  :mode (("\\.qmd\\'" . poly-markdown-mode)))

;; ---- File Management ----
(use-package recentf
  :init
  (recentf-mode 1)
  :config
  (setq recentf-max-saved-items 100))
(global-set-key (kbd "C-c r") #'recentf-open-files)

(with-eval-after-load 'ispell
  (setq ispell-program-name "aspell"
        ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")))

;; ---- Treemacs ----
(with-eval-after-load 'treemacs
  (treemacs-follow-mode t)
  (treemacs-project-follow-mode t))

;; ---- Gemini / AI ----
(use-package gptel
  :ensure t
  :config
  (setq gptel-default-mode 'org-mode
        gptel-model "gemini-2.5-pro"
        gptel-backend
        (gptel-make-gemini "Gemini"
          :key (gptel-api-key-from-auth-source "gemini.google.com")
          :stream t
          :models '("gemini-2.5-pro" "gemini-3-flash" "gemini-2.0-flash" "gemini-2.5-flash"))))

(global-set-key (kbd "C-c g c") #'gptel)
(global-set-key (kbd "C-c g s") #'gptel-send)
(global-set-key (kbd "C-c g m") #'gptel-menu)

;; ---- Web Browser & Environment Integration ----
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "xdg-open")

(setenv "PATH" (concat (getenv "PATH") ":" (expand-file-name "~/.nix-profile/bin")))
(add-to-list 'exec-path (expand-file-name "~/.nix-profile/bin"))

;; ---- Terminal (Vterm) ----
(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000
        vterm-kill-buffer-on-exit t))

(add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode -1)))
(global-set-key (kbd "C-c v") #'multi-vterm)

;; ---- Jujutsu (vc-jj) Integration ----
(use-package vc-jj
  :config
  (add-to-list 'vc-handled-backends 'jj))

;; ---- TRAMP (Remote Editing) ----
(require 'tramp)
(setq tramp-default-method "ssh"
      vc-ignore-dir-regexp (format "%s\\|%s" vc-ignore-dir-regexp tramp-file-name-regexp))

;; ---- Eglot & Grammar Checking ----
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((latex-mode tex-mode org-mode) . ("ltex-ls-plus")))
  (setq-default eglot-workspace-configuration
                '((ltex . ((language . "en-US")
                           (dictionary . (:en-US ["~/.ltex-dict.txt"])))))))

(add-hook 'latex-mode-hook #'eglot-ensure)
(add-hook 'tex-mode-hook #'eglot-ensure)

;; Prevent Emacs 30 track-changes assertion from aborting org-capture-finalize
(with-eval-after-load 'track-changes
  (advice-add 'track-changes--before :around
              (lambda (orig-fun &rest args)
                (condition-case nil
                    (apply orig-fun args)
                  (cl-assertion-failed nil)))))

(require 'server)
(unless (server-running-p)
  (server-start))
