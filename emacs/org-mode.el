;; Add 15% extra vertical space between all lines globally (put near the top)
(setq-default line-spacing 0.15)

;; Update your existing org-modern block at the bottom:
(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-agenda-time nil)
  ;; Add these two lines for clean list bullets and checkboxes
  (setq org-modern-list '((43 . "➤") (45 . "•") (42 . "◦")))
  (setq org-modern-checkbox '((?X . "✓") (?- . "[-]") (?  . "☐"))))


;; ---- Org Mode Setup ----
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
  (setq org-default-priority ?C)

  ;; Optional: Give each priority a specific color in the doom-one theme
  (setq org-priority-faces
      '((?A . 'error)       ; Red
        (?B . 'warning)     ; Orange/Yellow
        (?C . 'success)     ; Green
        (?D . 'highlight)   ; Blue
        (?E . 'shadow)))    ; Grey


  (setq org-capture-templates
        '(("t" "Todo Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n  Context: %a\n")
          ("n" "Quick Note" entry (file "~/org/notes.org")
           "* %?\n  %U\n  Context: %a\n")
          ("p" "General/Personal Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n")))

  ;; Define your strict two-state workflow
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROJECT(p)" "|" "DONE(d)")))

  ;; Set agenda to show exactly 1 day (change to 3 if you meant "three days")
  (setq org-agenda-span 3)

  (setq org-enforce-todo-checkbox-dependencies t)

  ;; Start on today rather than the beginning of the week
  (setq org-agenda-start-on-weekday nil)

  ;; Hide tags in the agenda so the text stays perfectly clean
  (setq org-agenda-hide-tags-regexp ".")

  ;; Remove the time grid if you don't schedule specific hourly appointments
  (setq org-agenda-use-time-grid nil)

  ;; Clean up the agenda prefix to remove the redundant file category
  (setq org-agenda-prefix-format
        '((agenda . " %i %?-12t% s")
          (todo   . " %i %-12:c")
          (tags   . " %i %-12:c")
          (search . " %i %-12:c"))))

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


(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  ;; Makes the agenda date headers look like clean section dividers
  (setq org-modern-agenda-time nil))

(use-package olivetti
  :ensure t
  :hook (org-agenda-mode . olivetti-mode)
  :config
  ;; Adjust this number to make the centered column wider or narrower
  (setq olivetti-body-width 80))

(add-hook 'org-agenda-mode-hook (lambda () (display-line-numbers-mode -1)))
