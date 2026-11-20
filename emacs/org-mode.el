;; Add 15% extra vertical space between all lines globally
(setq-default line-spacing 0.15)

;; ---- UI Polish: Org Modern, Olivetti & Fragtog ----
(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-agenda-time nil)
  (setq org-modern-list '((43 . "➤") (45 . "•") (42 . "◦")))
  (setq org-modern-checkbox '((88 . "✓") (45 . "[-]") (32 . "☐"))))

(use-package olivetti
  :ensure t
  :hook (org-agenda-mode . olivetti-mode)
  :config
  (setq olivetti-body-width 80))

(use-package org-fragtog
  :ensure t
  :hook (org-mode . org-fragtog-mode))

(add-hook 'org-agenda-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'org-mode-hook #'visual-line-mode)

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; ---- Core Org Mode Setup ----
(with-eval-after-load 'org
  (require 'org-protocol)
  (require 'org-tempo)
  (require 'org-capture)

  (setq org-directory "~/org"
        org-agenda-files '("~/org")
        org-default-notes-file "~/org/tasks.org"
        org-archive-location "~/org/archive/archive.org::")

  (setq org-refile-targets '((nil . (:maxlevel . 3)))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil)

  (setq org-agenda-custom-commands
        '(("u" "Unscheduled Backlog" alltodo ""
           ((org-agenda-todo-ignore-scheduled 'all)
            (org-agenda-todo-ignore-deadlines 'all)))))

  (setq org-hide-emphasis-markers t
        org-startup-indented t
        org-pretty-entities t
        org-startup-with-latex-preview t)

  ;; Expand priorities from A to E
  (setq org-highest-priority ?A
        org-lowest-priority ?E
        org-default-priority ?E)

  ;; Make priority letter strictly outweigh Scheduled/Deadline urgency boosts
  (advice-add 'org-get-priority :override
              (lambda (s)
                (* 100000 (- org-lowest-priority
                             (if (string-match org-priority-regexp s)
                                 (string-to-char (match-string 2 s))
                               org-default-priority)))))

  (setq org-priority-faces
        '((?A . error)
          (?B . warning)
          (?C . success)
          (?D . highlight)
          (?E . shadow)))

  (setq org-capture-templates
        '(("t" "Todo Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n  Context: %a\n")
          ("n" "Quick Note" entry (file "~/org/notes.org")
           "* %?\n  %U\n  Context: %a\n")
          ("p" "General/Personal Task" entry (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  %U\n")
          ("w" "Web Clip" entry (file "~/org/notes.org")
           "* %:annotation\nCaptured On: %U\n\n%i\n%?"
           :empty-lines 1)))

  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROJECT(p)" "|" "DONE(d)")))

  (setq org-agenda-span 3
        org-enforce-todo-checkbox-dependencies t
        org-agenda-start-on-weekday nil
        org-agenda-hide-tags-regexp "."
        org-agenda-use-time-grid nil)

  (setq org-agenda-prefix-format
        '((agenda . " %i %?-12t% s")
          (todo   . " %i %-12:c")
          (tags   . " %i %-12:c")
          (search . " %i %-12:c")))

  ;; Fast Code Block Expansion (<jp, <jj, <sh + TAB)
  (add-to-list 'org-structure-template-alist '("jp" . "src jupyter-python"))
  (add-to-list 'org-structure-template-alist '("jj" . "src jupyter-julia"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell")))

;; ---- Org Roam Setup ----
(defun my/org-roam-jump-links ()
  "Jump to any backlink (<-) or forward link (->) connected to the current node."
  (interactive)
  (require 'org-roam)
  (let* ((node (org-roam-node-at-point t))
         (id (org-roam-node-id node))
         (all-links (org-roam-db-query "SELECT source, dest, type FROM links"))
         back-ids
         fwd-ids
         candidates)
    (dolist (row all-links)
      (let ((src (nth 0 row))
            (dst (nth 1 row))
            (ltype (nth 2 row)))
        (when (equal ltype "id")
          (when (equal dst id)
            (cl-pushnew src back-ids :test #'equal))
          (when (equal src id)
            (cl-pushnew dst fwd-ids :test #'equal)))))
    (dolist (bid back-ids)
      (when-let ((n (org-roam-node-from-id bid)))
        (push (cons (format "<- [Backlink] %s" (org-roam-node-title n)) n)
              candidates)))
    (dolist (fid fwd-ids)
      (when-let ((n (org-roam-node-from-id fid)))
        (push (cons (format "-> [Forward]  %s" (org-roam-node-title n)) n)
              candidates)))
    (if (null candidates)
        (message "No backlinks or forward links for '%s'" (org-roam-node-title node))
      (let ((choice (completing-read
                     (format "Links for %s: " (org-roam-node-title node))
                     candidates nil t)))
        (when choice
          (org-roam-node-visit (cdr (assoc choice candidates))))))))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . my/org-roam-jump-links)
         ("C-c n s" . my/org-find-similar-notes)
         ("C-c n P" . my/org-roam-promote-archived-note))
  :config

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:PEOPLE:   \n:CREATED:  %U\n:END:\n#+title: ${title}\n#+filetags: \n\n")
           :unnarrowed t)
          ("p" "paper (org-noter)" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:PEOPLE:   \n:NOTER_DOCUMENT: %(read-file-name \"Select PDF: \" \"~/org/roam/pdfs/\")\n:CREATED:  %U\n:END:\n#+title: ${title}\n#+filetags: :paper:\n\n")
           :unnarrowed t)
          ("r" "reference (citar)" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${citar-citekey}.org"
                              ":PROPERTIES:\n:ID:       %<%Y%m%d%H%M%S>\n:PEOPLE:   ${citar-author}\n:NOTER_DOCUMENT: ~/org/roam/pdfs/${citar-citekey}.pdf\n:CREATED:  %U\n:END:\n#+title: ${title}\n#+filetags: :paper:\n\n* Notes\n")
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

;; ---- Non-AI Similar Note Suggester (~/org/roam + ~/org/obsidian_archive) ----
(require 'cl-lib)
(require 'subr-x)
(require 'seq)

(defvar my/org-note-search-directories
  '("~/org/roam" "~/org/obsidian_archive")
  "Directories scanned when suggesting similar Org notes.")

(defvar my/org-stopwords
  (let ((table (make-hash-table :test 'equal))
        (words '("the" "and" "for" "that" "this" "with" "from" "have" "are"
                 "was" "were" "been" "has" "had" "not" "but" "what" "all"
                 "when" "where" "who" "will" "more" "about" "into" "than"
                 "them" "then" "some" "could" "would" "should" "which" "their"
                 "there" "each" "other" "also" "after" "before" "through"
                 "between" "under" "over" "again" "further" "once" "here"
                 "very" "just" "only" "both" "such" "same" "so" "too" "can"
                 "using" "used" "use" "note" "notes" "file" "files" "org"
                 "title" "filetags" "properties" "created" "people" "end"
                 "begin" "src" "results" "http" "https" "www" "com" "true"
                 "false" "none" "null" "todo" "done" "project")))
    (dolist (w words) (puthash w t table))
    table)
  "Stopwords ignored during note similarity tokenization.")

(defun my/org-extract-note-features (text)
  "Return (TITLE . TERM-WEIGHTS-HASH) from raw Org TEXT."
  (let ((weights (make-hash-table :test 'equal))
        (case-fold-search t)
        (title "Untitled"))
    (when (string-match "^#\\+title:[ \t]*\\(.+\\)$" text)
      (setq title (string-trim (match-string 1 text)))
      (dolist (w (split-string (downcase title) "[^a-z0-9_]+" t))
        (when (and (>= (length w) 3) (not (gethash w my/org-stopwords)))
          (puthash w (+ (gethash w weights 0) 3.0) weights))))
    (when (string-match "^#\\+filetags:[ \t]*\\(.+\\)$" text)
      (let ((tags (match-string 1 text)))
        (dolist (w (split-string (downcase tags) "[^a-z0-9_]+" t))
          (when (and (>= (length w) 3) (not (gethash w my/org-stopwords)))
            (puthash w (+ (gethash w weights 0) 3.0) weights)))))
    (dolist (line (split-string text "\n" t))
      (unless (string-match-p "^[ \t]*\\(:\\|#\\+\\)" line)
        (dolist (w (split-string (downcase line) "[^a-z0-9_]+" t))
          (when (and (>= (length w) 3)
                     (not (string-match-p "^[0-9]+$" w))
                     (not (gethash w my/org-stopwords)))
            (puthash w (+ (gethash w weights 0) 1.0) weights)))))
    (cons title weights)))

(defun my/org-collect-all-note-files ()
  "Collect all readable .org files in `my/org-note-search-directories', ignoring lockfiles."
  (let (files)
    (dolist (dir my/org-note-search-directories)
      (let ((full-dir (expand-file-name dir)))
        (when (file-directory-p full-dir)
          (dolist (f (directory-files-recursively
                      full-dir "\\`[^.#].*\\.org\\'" nil
                      (lambda (d)
                        (not (string-prefix-p "." (file-name-nondirectory d))))))
            (when (and (file-regular-p f) (file-readable-p f))
              (push (file-truename f) files))))))
    (delete-dups files)))

(defun my/org-find-similar-notes (&optional top-n)
  "Find and open notes in ~/org/roam and ~/org/obsidian_archive similar to current buffer."
  (interactive)
  (let* ((limit (or top-n 15))
         (current-file (when buffer-file-name (file-truename buffer-file-name)))
         (source-text (buffer-substring-no-properties (point-min) (point-max)))
         (source-features (my/org-extract-note-features source-text))
         (source-weights (cdr source-features))
         (all-files (remove current-file (my/org-collect-all-note-files)))
         (doc-freq (make-hash-table :test 'equal))
         (doc-data nil)
         (total-docs (max 1 (length all-files)))
         (roam-prefix (file-truename (expand-file-name "~/org/roam"))))

    (when (zerop (hash-table-count source-weights))
      (user-error "Current buffer has no significant keywords to match"))

    (dolist (file all-files)
      (with-temp-buffer
        (insert-file-contents file nil 0 30000)
        (let* ((feats (my/org-extract-note-features (buffer-string)))
               (title (car feats))
               (weights (cdr feats)))
          (maphash (lambda (term _)
                     (when (gethash term source-weights)
                       (puthash term (1+ (gethash term doc-freq 0)) doc-freq)))
                   weights)
          (push (list file title weights) doc-data))))

    (let (scored)
      (dolist (doc doc-data)
        (let* ((file (nth 0 doc))
               (title (nth 1 doc))
               (target-weights (nth 2 doc))
               (score 0.0)
               (norm-target 0.0)
               (matched-terms nil))
          (maphash (lambda (_ w)
                     (setq norm-target (+ norm-target (* w w))))
                   target-weights)
          (setq norm-target (sqrt (max 1.0 norm-target)))

          (maphash
           (lambda (term src-w)
             (when-let ((tgt-w (gethash term target-weights)))
               (let* ((df (gethash term doc-freq 1))
                      (idf (1+ (log (/ (float total-docs) df))))
                      (contrib (* (min src-w 5.0) (min tgt-w 5.0) idf idf)))
                 (setq score (+ score contrib))
                 (push (cons contrib term) matched-terms))))
           source-weights)

          (when (> score 0)
            (let* ((final-score (/ score norm-target))
                   (top-terms (mapcar #'cdr
                                      (seq-take (sort matched-terms
                                                      (lambda (a b) (> (car a) (car b))))
                                                4)))
                   (origin (if (string-prefix-p roam-prefix file) "roam" "archive")))
              (push (list final-score file title origin top-terms) scored)))))

      (setq scored (seq-take (sort scored (lambda (a b) (> (car a) (car b)))) limit))
      (if (null scored)
          (message "No similar notes found across ~/org/roam or ~/org/obsidian_archive.")
        (let* ((candidates
                (mapcar (lambda (item)
                          (let ((score (nth 0 item))
                                (file (nth 1 item))
                                (title (nth 2 item))
                                (origin (nth 3 item))
                                (terms (nth 4 item)))
                            (cons (format "[%-7s | %5.1f] %-42s (shared: %s)"
                                          origin score
                                          (truncate-string-to-width title 42 nil nil "...")
                                          (string-join terms ", "))
                                  file)))
                        scored))
               (selection (completing-read "Similar notes: " candidates nil t)))
          (when selection
            (find-file (cdr (assoc selection candidates)))))))))

(defun my/org-roam-promote-archived-note ()
  "Promote current note from ~/org/obsidian_archive into ~/org/roam with an ID."
  (interactive)
  (require 'org-roam)
  (let ((archive-dir (file-truename (expand-file-name "~/org/obsidian_archive"))))
    (unless (and buffer-file-name
                 (string-prefix-p archive-dir (file-truename buffer-file-name)))
      (user-error "Current buffer is not inside ~/org/obsidian_archive"))
    (let* ((timestamp (format-time-string "%Y%m%d%H%M%S"))
           (slug (file-name-base buffer-file-name))
           (new-path (expand-file-name (format "%s-%s.org" timestamp slug)
                                       org-roam-directory)))
      (save-excursion
        (goto-char (point-min))
        (org-set-property "ID" timestamp))
      (save-buffer)
      (rename-file buffer-file-name new-path)
      (set-visited-file-name new-path t t)
      (org-roam-db-update-file new-path)
      (message "Promoted to active org-roam node: %s"
               (file-name-nondirectory new-path)))))

;; ---- Org Babel & emacs-jupyter Integration ----
(use-package jupyter
  :demand t
  :after org
  :config
  (setq jupyter-repl-echo-eval-p t)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)
     (jupyter . t)))

  (setq org-confirm-babel-evaluate nil
        org-startup-with-inline-images t)
  (add-hook 'org-babel-after-execute-hook #'org-display-inline-images 'append))

;; ---- Per-Buffer Flake Environment Activation ----
(use-package envrc
  :init
  (envrc-global-mode)
  :config
  (advice-add 'org-babel-execute-src-block :around #'envrc-propagate-environment))

;; ---- Seamless .ipynb Editing + Safe REPL Association ----
(defun my/code-cells-eval-with-jupyter (orig-fun &rest args)
  "Start and associate a Jupyter REPL if not connected; otherwise evaluate cell."
  (if (and (derived-mode-p 'python-base-mode 'julia-mode)
           (not (bound-and-true-p jupyter-repl-interaction-mode)))
      (let ((kernel (if (derived-mode-p 'julia-mode) "julia" "python3")))
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
