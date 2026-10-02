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

  (setq org-capture-templates
        '(("t" "Todo Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n  Context: %a\n")
          ("n" "Quick Note" entry (file "~/org/notes.org")
           "* %?\n  %U\n  Context: %a\n")
          ("p" "General/Personal Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n"))))

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
                              ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:NOTER_DOCUMENT: %(read-file-name \"Select PDF: \" \"~/Papers/\")\n:CREATED: %U\n:END:\n#+title: ${title}\n#+filetags: :paper: \n\n")
           :unnarrowed t)))
  (org-roam-db-autosync-mode))

(use-package org-roam-ui
  :ensure t
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

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
