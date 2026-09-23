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

      # ---- Quarto mode ----
      quarto-mode
      polymode
      poly-markdown
      julia-mode
      poly-R
      request

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

      org-roam
      org-roam-ui

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
        ;; Highlight the current file in the tree
        (treemacs-follow-mode t)

        ;; Automatically switch the tree to the current file's project/directory
        (treemacs-project-follow-mode t))

      ;; ---- Org Mode Setup ----

      (with-eval-after-load 'org
        ;; Core Directories
        (setq org-directory "~/org")
        (setq org-agenda-files '("~/org"))
        (setq org-default-notes-file "~/org/tasks.org")

       ;; Route all archived tasks to a single file
        (setq org-archive-location "~/org/archive/archive.org::")

        ;; custom agenda view
        (setq org-agenda-custom-commands
          '(("u" "Unscheduled Backlog" alltodo ""
             ((org-agenda-todo-ignore-scheduled 'all)
              (org-agenda-todo-ignore-deadlines 'all)))))

        ;; Appearance
        (setq org-hide-emphasis-markers t)
        (setq org-startup-indented t)

        ;; Capture Templates
        (setq org-capture-templates
            '(("t" "Todo Task" entry (file "~/org/tasks.org")
               "* TODO %?\n  %U\n  Context: %a\n")
              ("n" "Quick Note" entry (file "~/org/notes.org")
               "* %?\n  %U\n  Context: %a\n")
              ("p" "General/Personal Task" entry (file "~/org/tasks.org")
               "* TODO %?\n  %U\n"))))

      ;; Hooks and Global Keybindings (These remain outside the block so they are active immediately)
      (add-hook 'org-mode-hook #'visual-line-mode)
      (global-set-key (kbd "C-c l") 'org-store-link)
      (global-set-key (kbd "C-c a") 'org-agenda)
      (global-set-key (kbd "C-c c") 'org-capture)

      ;; ---- Org Roam Setup ----
      (use-package org-roam
        :ensure t
        :custom
        (org-roam-directory (file-truename "~/org/roam"))
        :bind (("C-c n l" . org-roam-buffer-toggle)
               ("C-c n f" . org-roam-node-find)
               ("C-c n i" . org-roam-node-insert)
               ("C-c n c" . org-roam-capture))
        :config
        ;; Replicate Obsidian metadata structure via Property Drawers

        (setq org-roam-capture-templates
          '(("d" "default" plain "%?"
             :target (file+head "%<%Y%m%d%H%M%S>-''${slug}.org"
                                ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:PEOPLE:  \n:CREATED: %U\n:END:\n#+title: ''${title}\n#+filetags: \n\n")
             :unnarrowed t)))

        (org-roam-db-autosync-mode))

      ;; ---- Org Roam UI Setup ----
      (use-package org-roam-ui
        :ensure t
        :after org-roam
        :config
        (setq org-roam-ui-sync-theme t
              org-roam-ui-follow t
              org-roam-ui-update-on-save t
              org-roam-ui-open-on-start nil))

    ;; ---- Quarto Mode ----

    (use-package polymode :ensure t)

    (use-package poly-markdown :ensure t :after polymode)

    (use-package poly-R :ensure t :after polymode)

    (use-package poly-markdown
      :ensure t
      :mode (("\\.qmd\\'" . poly-markdown-mode)))


    ;; ---- show recent buffer visits ----

    (recentf-mode 1)
    (setq recentf-max-saved-items 100)
    (global-set-key (kbd "C-c r") 'recentf-open-files)

    (global-auto-revert-mode t)

    ;; Move between Emacs tiles using C-x and Arrow Keys
    (global-set-key (kbd "C-x <left>")  'windmove-left)
    (global-set-key (kbd "C-x <right>") 'windmove-right)
    (global-set-key (kbd "C-x <up>")    'windmove-up)
    (global-set-key (kbd "C-x <down>")  'windmove-down)

    '';

  };
}
