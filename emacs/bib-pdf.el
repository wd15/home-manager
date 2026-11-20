;; ---- PDF Tools, Org Noter, and Bibliography (Biblio + Citar + Org-Roam) ----
(require 'cl-lib)
(require 'subr-x)
(require 'seq)

(declare-function biblio-cleanup-doi "biblio-doi")
(declare-function biblio-doi-forward-bibtex "biblio-doi")
(declare-function bibtex-beginning-of-entry "bibtex")
(declare-function bibtex-clean-entry "bibtex")
(declare-function bibtex-parse-entry "bibtex")
(declare-function citar-open-notes "citar")
(declare-function citar-refresh "citar")
(declare-function citar-select-ref "citar")
(declare-function citar-org-roam-mode "citar-org-roam")
(declare-function pdf-tools-install "pdf-tools")
(declare-function url-encode-url "url-util")

(defvar url-request-extra-headers)
(defvar url-http-response-status)
(defvar bibtex-autokey-edit-before-use)

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
  (setq org-noter-always-create-frame nil
        org-noter-hide-other t
        org-noter-notes-window-location '(horizontal . 0.3)
        split-width-threshold 100))

;; ---- Core Paths & Packages ----
(defvar my/bib-file (expand-file-name "~/org/references.bib")
  "Master BibTeX file managed without Zotero.")

(defvar my/bib-pdf-dir (expand-file-name "~/org/roam/pdfs/")
  "Directory storing citekey-named PDFs synced via rclone.")

(use-package oc
  :after org
  :custom
  (org-cite-global-bibliography (list my/bib-file))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar))

;; Auto-generate clean, filename-safe citekeys (e.g., author2025torchda)
(use-package bibtex
  :ensure nil
  :custom
  (bibtex-dialect 'biblatex)
  (bibtex-entry-format '(opts-or-alts numerical-fields whitespace realign last-comma))
  (bibtex-autokey-edit-before-use nil)
  (bibtex-autokey-names 1)
  (bibtex-autokey-year-length 4)
  (bibtex-autokey-name-year-separator "")
  (bibtex-autokey-year-title-separator "")
  (bibtex-autokey-titleword-length 'infty)
  (bibtex-autokey-titlewords 1)
  (bibtex-autokey-titlewords-stretch 0)
  (bibtex-autokey-titleword-separator "")
  (bibtex-autokey-name-case-convert-function #'downcase)
  (bibtex-autokey-titleword-case-convert-function #'downcase))

(use-package biblio
  :defer t
  :custom
  (biblio-bibtex-use-autokey t))

(use-package citar
  :defer t
  :custom
  (citar-bibliography (list my/bib-file))
  (citar-library-paths (list my/bib-pdf-dir))
  (citar-library-file-extensions '("pdf" "djvu" "epub"))
  (citar-file-open-functions '(("html" . citar-file-open-external)
                               (t . find-file)))
  :bind (("C-c b c" . org-cite-insert)
         ("C-c b o" . citar-open)
         ("C-c b f" . citar-open-files)
         ("C-c b n" . citar-open-notes)
         ("C-c b e" . citar-open-entry)))

(use-package citar-org-roam
  :after citar
  :custom
  (citar-org-roam-subdir nil)
  (citar-org-roam-capture-template-key "r")
  (citar-org-roam-note-title-template "${author editor} (${date year issued}) - ${title}")
  :bind (("C-c b r" . citar-org-roam-open-current-refs)
         ("C-c b C" . citar-org-roam-cited))
  :config
  (require 'org-roam)
  (citar-org-roam-mode 1))

;; ---- Bibliography Helpers (Single DOI, Batch DOI, PDF Move, Note Creation) ----
(defun my/bib-open ()
  "Open the master bibliography file."
  (interactive)
  (find-file my/bib-file))

(defun my/bib--doi-exists-p (doi)
  "Return non-nil if DOI already appears in `my/bib-file'."
  (when (file-exists-p my/bib-file)
    (with-temp-buffer
      (insert-file-contents my/bib-file)
      (let ((case-fold-search t))
        (goto-char (point-min))
        (search-forward doi nil t)))))

(defun my/bib--insert-and-clean-entry (bibtex-str)
  "Append BIBTEX-STR to `my/bib-file', clean its citekey, and return the key."
  (require 'bibtex)
  (let ((cleaned (string-trim (or bibtex-str ""))))
    (unless (string-prefix-p "@" cleaned)
      (user-error "Response did not contain a valid BibTeX entry"))
    (with-current-buffer (find-file-noselect my/bib-file)
      (unless (derived-mode-p 'bibtex-mode)
        (bibtex-mode))
      (goto-char (point-max))
      (unless (bobp)
        (unless (bolp) (insert "\n"))
        (unless (looking-back "\n\n" (max (point-min) (- (point) 2)))
          (insert "\n")))
      (let ((entry-start (point))
            (bibtex-autokey-edit-before-use nil))
        (insert cleaned "\n")
        (goto-char entry-start)
        (condition-case err
            (bibtex-clean-entry t)
          (error (message "BibTeX clean warning: %s"
                          (error-message-string err))))
        (bibtex-beginning-of-entry)
        (cdr (assoc "=key=" (bibtex-parse-entry)))))))

(defun my/bib--newest-download-pdf ()
  "Return the most recently modified PDF in ~/Downloads, or nil."
  (let ((downloads-dir (expand-file-name "~/Downloads/"))
        (case-fold-search t))
    (when (file-directory-p downloads-dir)
      (let ((pdfs (seq-filter #'file-regular-p
                              (directory-files downloads-dir t "\\.pdf\\'" t))))
        (car (sort pdfs
                   (lambda (a b)
                     (time-less-p
                      (file-attribute-modification-time (file-attributes b))
                      (file-attribute-modification-time (file-attributes a))))))))))

(defun my/bib--attach-pdf-for-key (key &optional optional-p)
  "Move a PDF from ~/Downloads/ into `my/bib-pdf-dir'/KEY.pdf.
When OPTIONAL-P is non-nil, allow skipping without aborting via C-g."
  (when (or (null key) (string-empty-p key) (string-match-p "[/:\\\\]" key))
    (user-error "Invalid citekey '%s'; fix it in %s first" key my/bib-file))
  (let* ((dest (expand-file-name (concat key ".pdf") my/bib-pdf-dir))
         (newest (my/bib--newest-download-pdf))
         (src
          (cond
           ((and newest
                 (y-or-n-p (format "Move newest PDF '%s' -> %s.pdf? "
                                   (file-name-nondirectory newest) key)))
            newest)
           ((or (not optional-p)
                (y-or-n-p (format "Select a different PDF for %s? " key)))
            (read-file-name
             (format "Select PDF for %s: " key)
             "~/Downloads/" nil t nil
             (lambda (f)
               (or (string-suffix-p "/" f)
                   (file-directory-p f)
                   (string-match-p "\\.pdf\\'" (downcase f))))))
           (t nil))))
    (when src
      (when (file-directory-p src)
        (user-error "Please select a PDF file, not a directory"))
      (make-directory my/bib-pdf-dir t)
      (when (or (not (file-exists-p dest))
                (y-or-n-p (format "%s already exists. Overwrite? " dest)))
        (rename-file src dest t)
        (when (fboundp 'citar-refresh)
          (citar-refresh))
        (message "Moved PDF to %s" dest)))))

(defun my/bib--on-doi-result (bibtex-str)
  "Insert BIBTEX-STR, clean citekey, optionally move PDF, and open org-roam note."
  (let ((key (my/bib--insert-and-clean-entry bibtex-str)))
    (with-current-buffer (find-file-noselect my/bib-file)
      (save-buffer))
    (when (fboundp 'citar-refresh)
      (citar-refresh))
    (message "Added %s to %s" key my/bib-file)
    (my/bib--attach-pdf-for-key key t)
    (when (y-or-n-p (format "Create/open org-roam literature note for %s? " key))
      (require 'citar)
      (require 'citar-org-roam)
      (unless (bound-and-true-p citar-org-roam-mode)
        (citar-org-roam-mode 1))
      (citar-open-notes (list key)))))

(defun my/bib-add-doi (doi)
  "Fetch BibTeX for DOI, clean citekey, optionally move PDF and open note."
  (interactive "sDOI: ")
  (require 'biblio)
  (let ((clean-doi (biblio-cleanup-doi doi)))
    (when (and (my/bib--doi-exists-p clean-doi)
               (not (y-or-n-p (format "DOI %s is already in %s. Add anyway? "
                                      clean-doi my/bib-file))))
      (user-error "Cancelled"))
    (message "Fetching BibTeX for %s..." clean-doi)
    (biblio-doi-forward-bibtex clean-doi #'my/bib--on-doi-result)))

(defun my/bib--fetch-doi-sync (doi)
  "Synchronously fetch BibTeX for DOI via doi.org content negotiation."
  (require 'url)
  (require 'url-util)
  (let* ((url (url-encode-url (concat "https://doi.org/" doi)))
         (url-request-extra-headers
          '(("Accept" . "application/x-bibtex; charset=utf-8")))
         (buf (url-retrieve-synchronously url t t 15)))
    (unless buf
      (error "Request timed out for %s" doi))
    (unwind-protect
        (with-current-buffer buf
          (let ((status (bound-and-true-p url-http-response-status)))
            (unless (and status (>= status 200) (< status 300))
              (error "HTTP %s for %s" (or status "error") doi)))
          (goto-char (point-min))
          (unless (re-search-forward "\r?\n\r?\n" nil t)
            (error "Malformed HTTP response for %s" doi))
          (decode-coding-string
           (string-trim (buffer-substring-no-properties (point) (point-max)))
           'utf-8))
      (kill-buffer buf))))

(defun my/bib--extract-dois (text)
  "Extract a deduplicated list of DOI strings from TEXT."
  (let ((pos 0)
        dois)
    (while (string-match
            "10\\.[0-9]\\{4,9\\}/[^ \t\n\r\"'<>\\[\\]{}|^`]+"
            text pos)
      (let ((raw (match-string 0 text)))
        (setq pos (match-end 0))
        (setq raw (replace-regexp-in-string "[.,;:]+\\'" "" raw))
        (while (and (string-suffix-p ")" raw)
                    (> (cl-count 41 raw) (cl-count 40 raw)))
          (setq raw (substring raw 0 -1)))
        (unless (member raw dois)
          (push raw dois))))
    (nreverse dois)))

(defun my/bib-add-dois-batch (text)
  "Fetch and append all DOIs found in active region or prompted TEXT."
  (interactive
   (list (if (use-region-p)
             (buffer-substring-no-properties (region-beginning) (region-end))
           (read-string "Paste DOIs or URLs (any separator): "))))
  (let* ((dois (my/bib--extract-dois text))
         (total (length dois))
         (idx 0)
         added skipped failed)
    (when (zerop total)
      (user-error "No valid DOIs found in input"))
    (dolist (doi dois)
      (setq idx (1+ idx))
      (if (my/bib--doi-exists-p doi)
          (progn
            (message "[%d/%d] Skipping duplicate DOI: %s" idx total doi)
            (push doi skipped))
        (message "[%d/%d] Fetching %s..." idx total doi)
        (condition-case err
            (let* ((bib (my/bib--fetch-doi-sync doi))
                   (key (my/bib--insert-and-clean-entry bib)))
              (push key added)
              (sit-for 0.3))
          (error
           (push (cons doi (error-message-string err)) failed)))))
    (when added
      (with-current-buffer (find-file-noselect my/bib-file)
        (save-buffer))
      (when (fboundp 'citar-refresh)
        (citar-refresh)))
    (message "Batch DOI import done: %d added, %d skipped, %d failed%s"
             (length added) (length skipped) (length failed)
             (if failed
                 (format " (failed: %s)"
                         (mapconcat #'car (nreverse failed) ", "))
               ""))))

(defun my/citar-attach-pdf ()
  "Pick an existing paper via Citar and move a PDF from ~/Downloads/ to `my/bib-pdf-dir'."
  (interactive)
  (require 'citar)
  (my/bib--attach-pdf-for-key (citar-select-ref)))

(defun my/bib-lookup ()
  "Search CrossRef, arXiv, IEEE, or DBLP and insert BibTeX into `my/bib-file'."
  (interactive)
  (require 'biblio)
  (find-file my/bib-file)
  (goto-char (point-max))
  (unless (bolp) (insert "\n"))
  (call-interactively #'biblio-lookup))

(global-set-key (kbd "C-c b b") #'my/bib-open)
(global-set-key (kbd "C-c b d") #'my/bib-add-doi)
(global-set-key (kbd "C-c b D") #'my/bib-add-dois-batch)
(global-set-key (kbd "C-c b a") #'my/citar-attach-pdf)
(global-set-key (kbd "C-c b l") #'my/bib-lookup)
