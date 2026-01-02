{ pkgs, ...}:
{
  enable=true;
  package=pkgs.emacs;
  extraPackages = (
     epkgs: (with epkgs; [
               better-defaults
               material-theme
               afternoon-theme
               yaml
               yaml-mode
               markdown-mode
               ox-pandoc
               use-package
	             solarized-theme
	             nix-mode
	             nixos-options
               python-mode
               elpy
               rainbow-identifiers
               haskell-mode
               git-commit
               gptel
            ])
   );

  extraConfig = ''
(setq standard-indent 2)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(defun shift-text (distance)
  (if (use-region-p)
      (let ((mark (mark)))
        (save-excursion
          (indent-rigidly (region-beginning)
                          (region-end)
                          distance)
          (push-mark mark t t)
          (setq deactivate-mark nil)))
    (indent-rigidly (line-beginning-position)
                    (line-end-position)
                    distance)))

(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(setq auto-mode-alist
   (cons '("\\.md" . markdown-mode) auto-mode-alist))

(define-key global-map "\C-l" 'goto-line)
(define-key global-map "\M-/" 'hippie-expand)
(define-key global-map "\C-t" 'comment-or-uncomment-region)

(load-theme 'solarized-dark t)

(require 'python-mode)
(require 'haskell-mode)
(require 'git-commit)
;;(elpy-enable)

(setq inhibit-startup-message t)
(global-display-line-numbers-mode 1)

(add-hook 'python-mode 'rainbow-identifiers-mode)

(set-face-foreground 'font-lock-comment-face "forest green")
(set-face-foreground 'font-lock-string-face "forest green")
(set-face-foreground 'font-lock-variable-name-face "cadet blue")

(add-hook 'before-save-hook 'my-prog-nuke-trailing-whitespace)

(defun my-prog-nuke-trailing-whitespace ()
  (when (derived-mode-p 'prog-mode)
    (delete-trailing-whitespace)))

;; insert spaces instead of tabs
(setq-default indent-tabs-mode nil)

;; insert new line at end of file
(setq require-final-newline t)

(setq-default fill-column 79)

;; using Gemini

(use-package gptel
  :ensure t
  :config
  (setq gptel-default-mode 'org-mode)

  (setq
   ;; 1. Set the default model (MUST be a string, not a symbol)
   gptel-model "gemini-2.5-pro"

   ;; 2. Define the backend
   gptel-backend
   (gptel-make-gemini "Gemini"
     :key (gptel-api-key-from-auth-source "gemini.google.com")
     :stream t
     :models '("gemini-2.5-pro"    ;; Complex tasks
               "gemini-3-flash"    ;; Fast/Chat
               "gemini-2.0-flash"  ;; Fallback
               "gemini-2.5-flash"))))

;; Recommended Keybindings
(global-set-key (kbd "C-c g c") 'gptel)       ;; Start a new chat buffer
(global-set-key (kbd "C-c g s") 'gptel-send)  ;; Send current region/buffer to Gemini
(global-set-key (kbd "C-c g m") 'gptel-menu)  ;; Open the menu to change models/settings


  '';

}
