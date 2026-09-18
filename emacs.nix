{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;

    extraPackages = epkgs: with epkgs; [
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

      # ---- Added for DOOM look/feel ----
      doom-themes        # DOOM's actual color themes (doom-one, doom-solarized-dark, etc.)
      doom-modeline      # DOOM's clean modeline
      all-the-icons      # icon set doom-modeline expects
      nerd-icons         # newer icon set some doom-themes faces prefer; harmless to have both

      # ---- Optional: DOOM's minibuffer completion feel ----
      vertico
      marginalia
      orderless

      # ---- Minimap + file tree sidebar ----
      minimap
      treemacs
      treemacs-all-the-icons   # wires treemacs into the icon set you already added
    ];

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

      ;; ---- Replaced solarized-dark load with doom-themes ----
      ;; If you'd rather keep your old solarized look exactly as it was,
      ;; just delete these two lines and restore:
      ;;   (load-theme 'solarized-dark t)
      (require 'doom-themes)
      (load-theme 'doom-one t)   ; try also: doom-solarized-dark, doom-dracula, doom-nord

      ;; doom-themes extras that make the look feel complete
      (doom-themes-visual-bell-config)
      (doom-themes-org-config)   ; nicer org-mode fontification, harmless if you don't use org

      ;; ---- DOOM-style modeline ----
      (require 'doom-modeline)
      (doom-modeline-mode 1)
      (setq doom-modeline-height 25)
      (setq doom-modeline-icon t)  ; requires all-the-icons fonts installed once, see note below

      (require 'python-mode)
      (require 'haskell-mode)
      (require 'git-commit)
      ;;(elpy-enable)

      (setq inhibit-startup-message t)
      (global-display-line-numbers-mode 1)

      (add-hook 'python-mode 'rainbow-identifiers-mode)

      ;; NOTE: these manual face overrides fight with doom-themes' own
      ;; syntax highlighting -- commented out since doom-one already
      ;; styles comments/strings/variables coherently. Uncomment if
      ;; you still want your old hand-picked colors instead.
      ;; (set-face-foreground 'font-lock-comment-face "forest green")
      ;; (set-face-foreground 'font-lock-string-face "forest green")
      ;; (set-face-foreground 'font-lock-variable-name-face "cadet blue")

      (add-hook 'before-save-hook 'my-prog-nuke-trailing-whitespace)

      (defun my-prog-nuke-trailing-whitespace ()
        (when (derived-mode-p 'prog-mode)
          (delete-trailing-whitespace)))

      ;; insert spaces instead of tabs
      (setq-default indent-tabs-mode nil)

      ;; insert new line at end of file
      (setq require-final-newline t)

      (setq-default fill-column 79)

      ;; ---- DOOM-style minibuffer completion (optional) ----
      (vertico-mode 1)
      (marginalia-mode 1)
      (setq completion-styles '(orderless basic))

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

      ;; Opens Treemacs for standard non-daemon startup (e.g., on your cluster)
      (add-hook 'emacs-startup-hook #'treemacs)

      ;; Opens Treemacs when creating a new frame via emacsclient (e.g., on your laptop)
      (add-hook 'server-after-make-frame-hook #'treemacs)

      (with-eval-after-load 'treemacs
        (treemacs-follow-mode 1))

      ;; ---- Org Mode Setup ----
      (with-eval-after-load 'org
      ;; Define where your notes live
      (setq org-directory "~/git/org")
      ;; Tell the agenda to look in this directory
      (setq org-agenda-files '("~/git/org"))
      ;; Hide formatting markers like *bold* and /italic/
      (setq org-hide-emphasis-markers t)
      ;; Automatically indent text under headers
      (setq org-startup-indented t))

      ;; Enable word wrap for writing
      (add-hook 'org-mode-hook #'visual-line-mode)

      ;; Essential global keybindings
      (global-set-key (kbd "C-c l") 'org-store-link)
      (global-set-key (kbd "C-c a") 'org-agenda)
      (global-set-key (kbd "C-c c") 'org-capture)

      (with-eval-after-load 'org
      ;; ... your existing directory and agenda settings ...

      ;; Set the default file for notes
      (setq org-default-notes-file "~/org/tasks.org")

      ;; Define your capture templates
      (setq org-capture-templates
          '(("t" "Todo Task" entry (file "~/git/org/tasks.org")
             "* TODO %?\n  %U\n  Context: %a\n")
            ("n" "Quick Note" entry (file "~/git/org/notes.org")
             "* %?\n  %U\n  Context: %a\n")
            ;; "p" for general/personal tasks without any file links
            ("p" "General/Personal Task" entry (file "~/git/org/tasks.org")
            "* TODO %?\n  %U\n"))))

    '';
  };


}
