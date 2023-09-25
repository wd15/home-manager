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

(load-theme 'solarized-dark t)

(require 'python-mode)
;;(elpy-enable)

(setq inhibit-startup-message t)
(global-linum-mode t)

(add-hook 'python-mode 'rainbow-identifiers-mode)

(set-face-foreground 'font-lock-comment-face "forest green")
(set-face-foreground 'font-lock-string-face "forest green")
(set-face-foreground 'font-lock-variable-name-face "cadet blue")
  '';

}
