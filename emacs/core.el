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
(load-theme 'doom-one t)
(doom-themes-visual-bell-config)
(doom-themes-org-config)

(require 'doom-modeline)
(doom-modeline-mode 1)
(setq doom-modeline-height 25)
(setq doom-modeline-icon t)

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
(add-hook 'emacs-startup-hook #'treemacs)
(add-hook 'server-after-make-frame-hook #'treemacs)
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
