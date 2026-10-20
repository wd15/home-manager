;; Add 15% extra vertical space between all lines globally
(setq-default line-spacing 0.15)

;; ---- UI Polish: Org Modern & Olivetti ----
(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-agenda-time nil)
  (setq org-modern-list '((43 . "➤") (45 . "•") (42 . "◦")))
  (setq org-modern-checkbox '((?X . "✓") (?- . "[-]") (?  . "☐"))))

(use-package olivetti
  :ensure t
  :hook (org-agenda-mode . olivetti-mode)
  :config
  (setq olivetti-body-width 80))

(add-hook 'org-agenda-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'org-mode-hook #'visual-line-mode)

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; ---- Core Org Mode Setup ----
(with-eval-after-load 'org
  (setq org-directory "~/org")
  (setq org-agenda-files '("~/org"))
  (setq org-default-notes-file "~/org/tasks.org")

  (setq org-refile-targets '((nil . (:maxlevel . 3))))
  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)

  (setq org-archive-location "~/org/archive/archive.org::")

  (setq org-agenda-custom-commands
        '(("u" "Unscheduled Backlog" alltodo ""
           ((org-agenda-todo-ignore-scheduled 'all)
            (org-agenda-todo-ignore-deadlines 'all)))))

  (setq org-hide-emphasis-markers t)
  (setq org-startup-indented t)

  ;; Expand priorities from A to E
  (setq org-highest-priority ?A)
  (setq org-lowest-priority ?E)
  (setq org-default-priority ?E)

  ;; Make priority letter strictly outweigh Scheduled/Deadline urgency boosts
  (advice-add 'org-get-priority :override
              (lambda (s)
                (* 100000 (- org-lowest-priority
                             (if (string-match org-priority-regexp s)
                                 (string-to-char (match-string 2 s))
                               org-default-priority)))))

  ;; Fixed: Removed inner quotes that caused "Invalid face reference: quote"
  (setq org-priority-faces
        '((?A . error)     ; Red
          (?B . warning)   ; Orange/Yellow
          (?C . success)   ; Green
          (?D . highlight) ; Blue
          (?E . shadow)))  ; Grey

  (setq org-capture-templates
        '(("t" "Todo Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n  Context: %a\n")
          ("n" "Quick Note" entry (file "~/org/notes.org")
           "* %?\n  %U\n  Context: %a\n")
          ("p" "General/Personal Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n")))

  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROJECT(p)" "|" "DONE(d)")))

  (setq org-agenda-span 3)
  (setq org-enforce-todo-checkbox-dependencies t)
  (setq org-agenda-start-on-weekday nil)
  (setq org-agenda-hide-tags-regexp ".")
  (setq org-agenda-use-time-grid nil)

  (setq org-agenda-prefix-format
        '((agenda . " %i %?-12t% s")
          (todo   . " %i %-12:c")
          (tags   . " %i %-12:c")
          (search . " %i %-12:c")))

  ;; Fast Code Block Expansion (<jp, <jj, <sh + TAB)
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("jp" . "src jupyter-python"))
  (add-to-list 'org-structure-template-alist '("jj" . "src jupyter-julia"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell")))

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
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:PEOPLE:  \n:CREATED: %U\n:END:\n#+title: ${title}\n#+filetags: \n\n")
           :unnarrowed t)
          ("p" "paper (org-noter)" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:PEOPLE:   \n:NOTER_DOCUMENT: %(read-file-name \"Select PDF: \" \"~/Papers/\")\n:CREATED: %U\n:END:\n#+title: ${title}\n#+filetags: :paper: \n\n")
           :unnarrowed t)))
  (org-roam-db-autosync-mode))

(use-package org-roam-ui
  :ensure t
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; ---- PDF Tools & Org Noter ----
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (setq-default pdf-view-display-size 'fit-width)
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1))))

(use-package org-noter
  :after (:any org pdf-view)
  :config
  (setq org-noter-always-create-frame nil)
  (setq org-noter-hide-other t)
  (setq org-noter-notes-window-location '(horizontal . 0.3))
  (setq split-width-threshold 100))

;; ---- Org Babel & emacs-jupyter Integration ----
(use-package jupyter
  :demand t
  :after org
  :config
  ;; Print evaluated code cells and plots directly in the REPL buffer
  (setq jupyter-repl-echo-eval-p t)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)
     (jupyter . t))) ; MUST be last in the list

  (setq org-confirm-babel-evaluate nil)
  (setq org-startup-with-inline-images t)
  (add-hook 'org-babel-after-execute-hook #'org-display-inline-images 'append))

;; ---- Per-Buffer Flake Environment Activation ----
(use-package envrc
  :init
  (envrc-global-mode)
  :config
  ;; Ensure Org Babel subprocesses and :dir headers inherit the flake's .envrc
  (advice-add 'org-babel-execute-src-block :around #'envrc-propagate-environment))

;; ---- Seamless .ipynb Editing + Safe REPL Association ----
(defun my/code-cells-eval-with-jupyter (orig-fun &rest args)
  "Start and associate a Jupyter REPL if not connected; otherwise evaluate cell."
  (if (and (derived-mode-p 'python-base-mode 'julia-mode)
           (not (bound-and-true-p jupyter-repl-interaction-mode)))
      (let ((kernel (if (derived-mode-p 'julia-mode) "julia" "python3")))
        ;; Start kernel, associate with current buffer, and show REPL window
        (jupyter-run-repl kernel nil t nil t)
        (message "Starting %s kernel... Press C-c C-c again once In [1]: appears." kernel))
    (apply orig-fun args)))

(use-package code-cells
  :init
  (add-to-list 'auto-mode-alist '("\\.ipynb\\'" . code-cells-convert-ipynb))
  :config
  (advice-add 'code-cells-eval :around #'my/code-cells-eval-with-jupyter)
  :bind (:map code-cells-mode-map
              ("C-c C-c" . code-cells-eval)
              ("M-p"     . code-cells-backward-cell)
              ("M-n"     . code-cells-forward-cell)))
