;;; init.el --- Emacs main configuration file -*- lexical-binding: t; buffer-read-only: t; no-byte-compile: t -*-
;;;
;;; Commentary:
;;; Emacs config by Andrey Orst.
;;; This file was automatically generated by `org-babel-tangle'.
;;; Do not change this file.  Main config is located in .emacs.d/config.org
;;;
;;; Code:

(defvar my--gc-cons-threshold gc-cons-threshold)
(defvar my--gc-cons-percentage gc-cons-percentage)
(defvar my--file-name-handler-alist file-name-handler-alist)

(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      message-log-max 16384
      file-name-handler-alist nil)

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold my--gc-cons-threshold
                  gc-cons-percentage my--gc-cons-percentage
                  file-name-handler-alist my--file-name-handler-alist)))

(setq ring-bell-function 'ignore)

(setq backup-by-copying t
      create-lockfiles nil
      backup-directory-alist '(("." . "~/.cache/emacs-backups"))
      auto-save-file-name-transforms '((".*" "~/.cache/emacs-backups" t)))

(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'after-init-hook (lambda () (setq echo-keystrokes 5)))

(global-unset-key (kbd "S-<down-mouse-1>"))
(global-unset-key (kbd "<mouse-3>"))
(global-unset-key (kbd "S-<mouse-3>"))

(setq-default indent-tabs-mode nil
              scroll-step 1
              mouse-wheel-progressive-speed nil
              auto-window-vscroll nil)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :noerror)

(defvar disabled-commands (expand-file-name ".disabled.el" user-emacs-directory)
  "File to store disabled commands, that were enabled permamently.")
(defadvice en/disable-command (around put-in-custom-file activate)
  "Put declarations in disabled.el."
  (let ((user-init-file disabled-commands))
    ad-do-it))
(load disabled-commands :noerror)

(savehist-mode 1)

(setq default-input-method 'russian-computer)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; suppress byte-compiler warnings
(declare-function minibuffer-keyboard-quit "delsel" (&optional ARGS))

(defun aorst/escape ()
  "Quit in current context.

When there is an active minibuffer and we are not inside it close
it.  When we are inside the minibuffer use the regular
`minibuffer-keyboard-quit' which quits any active region before
exiting.  When there is no minibuffer `keyboard-quit' unless we
are defining or executing a macro."
  (interactive)
  (cond ((active-minibuffer-window)
         (if (minibufferp)
             (minibuffer-keyboard-quit)
           (abort-recursive-edit)))
        ((bound-and-true-p iedit-mode)
         (iedit-quit))
        (t
         ;; ignore top level quits for macros
         (unless (or defining-kbd-macro executing-kbd-macro)
           (keyboard-quit)))))
(global-set-key [remap keyboard-quit] #'aorst/escape)

(defun aorst/command-error-function (data context caller)
  "Ignore the `text-read-only' signal; pass the rest DATA CONTEXT CALLER to the default handler."
  (when (not (eq (car data) 'text-read-only))
    (command-error-default-function data context caller)))

(setq command-error-function #'aorst/command-error-function)

(prefer-coding-system 'utf-8)
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

(setq inhibit-splash-screen t
      initial-major-mode 'fundamental-mode
      initial-scratch-message "")

(tooltip-mode -1)
(menu-bar-mode -1)
(fset 'menu-bar-open nil)

(when window-system
  (scroll-bar-mode -1)
  (tool-bar-mode -1))

(when window-system
  (setq-default cursor-type 'bar
                cursor-in-non-selected-windows nil))

(setq-default frame-title-format '("%b — Emacs"))

(when window-system
  (set-frame-size (selected-frame) 190 52))

(set-face-attribute 'default nil :font "Source Code Pro-10")

(setq column-number-mode nil
      line-number-mode nil
      size-indication-mode nil
      mode-line-position nil
      mode-line-in-non-selected-windows nil)

(defvar package--init-file-ensured)
(setq package-enable-at-startup nil
      package--init-file-ensured t)

(defvar package-archives)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(when (version= emacs-version "26.2")
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package)
  (setq use-package-always-ensure t))

(use-package compdef)

(use-package org
  :ensure nil
  :defines default-justification
  :hook ((org-mode . flyspell-mode)
         (org-mode . auto-fill-mode)
         (after-save . aorst/org-tangle-on-config-save)
         (org-babel-after-execute . aorst/org-update-inline-images)
         (org-mode . aorst/org-init-setup)
         ((org-capture-mode org-src-mode) . aorst/discard-history))
  :bind (:map org-mode-map
              ([backtab] . nil)
              ([S-iso-lefttab] . nil)
              ([C-tab] . org-shifttab)
              ("C-c l" . org-store-link))
  :config
  (use-package ox-latex
    :ensure nil)
  (setq org-startup-with-inline-images t
        org-startup-folded 'content
        org-hide-emphasis-markers t
        org-adapt-indentation nil
        org-hide-leading-stars t
        org-highlight-latex-and-related '(latex)
        revert-without-query '(".*\.pdf")
        org-preview-latex-default-process 'dvisvgm
        org-src-fontify-natively t
        org-preview-latex-image-directory ".ltximg/"
        org-latex-listings 'minted
        org-latex-pdf-process '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
                                "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
                                "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f")
        org-confirm-babel-evaluate nil
        org-imenu-depth 8
        org-agenda-files (file-truename "~/Documents/Agendas/"))
  (defun aorst/org-tangle-on-config-save ()
    "Tangle source code blocks when configuration file is saved."
    (when (string= buffer-file-name (file-truename "~/.emacs.d/config.org"))
      (org-babel-tangle)))
  (defun aorst/org-update-inline-images ()
    "Update inline images in Org-mode."
    (when org-inline-image-overlays
      (org-redisplay-inline-images)))
  (defun aorst/org-init-setup ()
    "Set buffer local values."
    (setq default-justification 'full))
  (defun aorst/discard-history ()
    "Discard undo history of org src and capture blocks."
    (setq buffer-undo-list nil)
    (set-buffer-modified-p nil))
  (defvar minted-cache-dir
    (file-name-as-directory
     (expand-file-name ".minted/\\jombname"
                       temporary-file-directory)))
  (add-to-list 'org-latex-packages-alist
               `(,(concat "cachedir=" minted-cache-dir)
                 "minted" nil))
  (add-to-list 'org-latex-logfiles-extensions "tex")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((gnuplot . t)
     (scheme . t)))
  (add-to-list 'org-latex-classes
               '("article"
                 "\\documentclass{article}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

(setq-default doc-view-resolution 192)

(use-package display-line-numbers
  :ensure nil
  :config
  (setq display-line-numbers-grow-only t
        display-line-numbers-width-start t))

(use-package prog-mode
  :ensure nil
  :hook ((prog-mode . show-paren-mode)
         (prog-mode . display-line-numbers-mode)))

(use-package cc-mode
  :ensure nil
  :config (defun aorst/cc-mode-setup ()
            (setq c-basic-offset 4
                  c-default-style "linux"
                  indent-tabs-mode t
                  tab-width 4))
  :hook ((c-mode-common . aorst/cc-mode-setup)
         (c-mode-common . electric-pair-local-mode)))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config
  (use-package edit-indirect)
  (defvar markdown-command "multimarkdown")
  (defun aorst/markdown-setup ()
    "Set buffer local variables."
    (setq fill-column 80
          default-justification 'left))
  :hook ((markdown-mode . flyspell-mode)
         (markdown-mode . auto-fill-mode)
         (markdown-mode . aorst/markdown-setup)))

(use-package rust-mode
  :commands (rust-format-buffer)
  :hook (rust-mode . electric-pair-local-mode)
  :bind (:map rust-mode-map
              ("C-c C-f" . rust-format-buffer)))

(when (executable-find "racer")
  (use-package racer
    :hook (racer-mode . eldoc-mode)
    :config (defun org-babel-edit-prep:rust (&optional _babel-info)
              "Run racer mode for Org Babel."
              (racer-mode 1))))

(when (executable-find "cargo")
  (use-package cargo
    :hook (rust-mode . cargo-minor-mode)))

(use-package toml-mode)

(use-package racket-mode
  :mode ("\\.rkt\\'" . racket-mode)
  :hook (racket-repl-mode . electric-pair-local-mode)
  :bind (:map racket-mode-map
              ("C-c C-d" . racket-run-with-debugging))
  :config (when (fboundp 'doom-color)
            (progn
              (set-face-attribute 'racket-debug-break-face nil :background (doom-color 'red) :foreground (doom-color 'base0))
              (set-face-attribute 'racket-debug-result-face nil :foreground (doom-color 'grey) :box nil)
              (set-face-attribute 'racket-debug-locals-face nil :foreground (doom-color 'grey) :box nil)
              (set-face-attribute 'racket-selfeval-face nil :foreground (doom-color 'fg)))))

(use-package cmake-mode)

(use-package all-the-icons)

(use-package doom-themes
  :commands (doom-themes-org-config)
  :config
  (doom-themes-org-config)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  :init (load-theme 'doom-one t))

(when window-system
  (use-package frame
    :ensure nil
    :config
    (add-to-list 'after-make-frame-functions #'aorst/set-frame-dark)
    (setq window-divider-default-right-width 1)
    (window-divider-mode 1)
    :init
    (defun aorst/set-frame-dark (&optional frame)
      "Set FRAME titlebar colorscheme to dark variant."
      (with-selected-frame (or frame (selected-frame))
        (call-process-shell-command
         (format "xprop -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT \"dark\" -name \"%s\""
                 (frame-parameter frame 'name)))))
    (aorst/set-frame-dark)))

(use-package solaire-mode
  :commands (solaire-global-mode
             solaire-mode-swap-bg
             turn-on-solaire-mode
             solaire-mode-in-minibuffer
             solaire-mode-reset)
  :hook (((after-revert
           change-major-mode
           org-capture-mode
           org-src-mode) . turn-on-solaire-mode)
         (snippet-mode . solaire-mode))
  :config
  (defun aorst/real-buffer-p ()
    "Determines whether buffer is real."
    (or (and (not (minibufferp))
             (buffer-file-name))
        (or (string-equal "*scratch*" (buffer-name))
            (string-match-p ".~{index}~" (buffer-name)))))
  (setq solaire-mode-real-buffer-fn #'aorst/real-buffer-p)
  (solaire-mode-swap-bg)
  (cond ((not (boundp 'after-focus-change-function))
         (add-hook 'focus-in-hook  #'solaire-mode-reset))
        (t
         (add-function :after after-focus-change-function #'solaire-mode-reset)))
  :init (solaire-global-mode +1))

(use-package fringe
  :ensure nil
  :hook ((window-configuration-change
          org-capture-mode
          org-src-mode
          ediff-after-setup-windows) . aorst/real-buffer-setup)
  :config
  (defun aorst/real-buffer-setup (&rest _)
    "Wrapper around `set-window-fringes' function."
    (when (aorst/real-buffer-p)
      (set-window-fringes nil 8 8 nil)
      (when (and (fboundp 'doom-color)
                 window-system)
        (set-face-attribute 'line-number-current-line nil
                            :foreground (doom-color 'fg-alt)
                            :background (doom-color 'bg)))
      (setq-local scroll-margin 3)))
  :init
  (when window-system
    (fringe-mode 0)
    (or standard-display-table
        (setq standard-display-table (make-display-table)))
    (set-display-table-slot standard-display-table 0 ?\ )))

(use-package doom-modeline
  :commands (doom-modeline-mode
             doom-modeline-set-selected-window
             doom-modeline-lsp-icon)
  :functions (doom-color)
  :config
  (dolist (face '(doom-modeline-buffer-modified
                  doom-modeline-buffer-minor-mode
                  doom-modeline-project-parent-dir
                  doom-modeline-project-dir
                  doom-modeline-project-root-dir
                  doom-modeline-highlight
                  doom-modeline-debug
                  doom-modeline-info
                  doom-modeline-warning
                  doom-modeline-urgent
                  doom-modeline-unread-number
                  doom-modeline-buffer-path
                  doom-modeline-bar
                  doom-modeline-panel
                  doom-modeline-buffer-major-mode
                  doom-modeline-buffer-file
                  doom-modeline-lsp-success
                  doom-modeline-lsp-warning
                  doom-modeline-lsp-error))
    (set-face-attribute face nil :foreground (doom-color 'fg) :weight 'normal))
  (set-face-attribute 'doom-modeline-buffer-file nil :weight 'semi-bold)
  (set-face-attribute 'doom-modeline-buffer-major-mode nil :weight 'semi-bold)
  (set-face-attribute 'doom-modeline-panel nil :background (doom-color 'bg-alt))
  (set-face-attribute 'doom-modeline-bar nil :background (doom-color 'bg-alt))
  (setq doom-modeline-bar-width 3
        doom-modeline-major-mode-color-icon nil
        doom-modeline-buffer-file-name-style 'file-name
        doom-modeline-minor-modes t
        find-file-visit-truename t)
  :init (doom-modeline-mode 1))

(when window-system
  (use-package treemacs
    :commands (treemacs
               treemacs-follow-mode
               treemacs-filewatch-mode
               treemacs-fringe-indicator-mode
               treemacs--expand-root-node
               treemacs--maybe-recenter
               treemacs-TAB-action
               treemacs-load-theme
               treemacs-toggle-fixed-width)
    :functions (aorst/treemacs-expand-all-projects
                aorst/treemacs-variable-pitch-labels
                aorst/tremacs-init-setup
                aorst/treemacs-setup
                aorst/treemacs-setup-fringes
                doom-color
                all-the-icons-octicon)
    :bind (("<f7>" . treemacs)
           ("<f8>" . treemacs-select-window)
           :map treemacs-mode-map
           ([C-tab] . aorst/treemacs-expand-all-projects))
    :hook ((after-init . aorst/treemacs-init-setup)
           (treemacs-mode . aorst/treemacs-setup)
           (treemacs-switch-workspace . aorst/treemacs-expand-all-projects)
           (treemacs-mode . aorst/treemacs-setup-title))
    :config
    (use-package treemacs-magit)
    (set-face-attribute 'treemacs-root-face nil
                        :foreground (doom-color 'fg)
                        :height 1.0
                        :weight 'normal)
    (treemacs-create-theme "Atom"
      :config
      (progn
        (treemacs-create-icon
         :icon (format " %s\t"
                       (all-the-icons-octicon
                        "repo"
                        :v-adjust -0.1
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (root))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-down"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "file-directory"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (dir-open))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-right"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "file-directory"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (dir-closed))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-down"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "package"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (tag-open))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-right"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "package"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (tag-closed))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "tag"
                        :height 0.9
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (tag-leaf))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "flame"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (error))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "stop"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (warning))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "info"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (info))
        (treemacs-create-icon
         :icon (format "  %s\t"
                       (all-the-icons-octicon
                        "file-media"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("png" "jpg" "jpeg" "gif" "ico" "tif" "tiff" "svg" "bmp"
                      "psd" "ai" "eps" "indd" "mov" "avi" "mp4" "webm" "mkv"
                      "wav" "mp3" "ogg" "midi"))
        (treemacs-create-icon
         :icon (format "  %s\t"
                       (all-the-icons-octicon
                        "file-code"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("yml" "yaml" "sh" "zsh" "fish" "c" "h" "cpp" "cxx" "hpp"
                      "tpp" "cc" "hh" "hs" "lhs" "cabal" "py" "pyc" "rs" "el"
                      "elc" "clj" "cljs" "cljc" "ts" "tsx" "vue" "css" "html"
                      "htm" "dart" "java" "kt" "scala" "sbt" "go" "js" "jsx"
                      "hy" "json" "jl" "ex" "exs" "eex" "ml" "mli" "pp" "dockerfile"
                      "vagrantfile" "j2" "jinja2" "tex" "racket" "rkt" "rktl" "rktd"
                      "scrbl" "scribble" "plt" "makefile" "elm" "xml" "xsl" "rb"
                      "scss" "lua" "lisp" "scm" "sql" "toml" "nim" "pl" "pm" "perl"
                      "vimrc" "tridactylrc" "vimperatorrc" "ideavimrc" "vrapperrc"
                      "cask" "r" "re" "rei" "bashrc" "zshrc" "inputrc" "editorconfig"
                      "gitconfig"))
        (treemacs-create-icon
         :icon (format "  %s\t"
                       (all-the-icons-octicon
                        "book"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("lrf" "lrx" "cbr" "cbz" "cb7" "cbt" "cba" "chm" "djvu"
                      "doc" "docx" "pdb" "pdb" "fb2" "xeb" "ceb" "inf" "azw"
                      "azw3" "kf8" "kfx" "lit" "prc" "mobi" "pkg" "opf" "txt"
                      "pdb" "ps" "rtf" "pdg" "xml" "tr2" "tr3" "oxps" "xps"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-text"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("md" "markdown" "rst" "log" "org" "txt"
                      "CONTRIBUTE" "LICENSE" "README" "CHANGELOG"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-binary"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("exe" "dll" "obj" "so" "o" "out"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-pdf"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("pdf"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-zip"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("zip" "7z" "tar" "gz" "rar" "tgz"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-text"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (fallback))))
    (defun aorst/treemacs-expand-all-projects (&optional _)
      "Expand all projects."
      (interactive)
      (save-excursion
        (treemacs--forget-last-highlight)
        (dolist (project (treemacs-workspace->projects (treemacs-current-workspace)))
          (-when-let (pos (treemacs-project->position project))
            (when (eq 'root-node-closed (treemacs-button-get pos :state))
              (goto-char pos)
              (treemacs--expand-root-node pos)))))
      (treemacs--maybe-recenter 'on-distance))
    (defun aorst/treemacs-variable-pitch-labels (&rest _)
      (dolist (face '(treemacs-root-face
                      treemacs-git-unmodified-face
                      treemacs-git-modified-face
                      treemacs-git-renamed-face
                      treemacs-git-ignored-face
                      treemacs-git-untracked-face
                      treemacs-git-added-face
                      treemacs-git-conflict-face
                      treemacs-directory-face
                      treemacs-directory-collapsed-face
                      treemacs-file-face
                      treemacs-tags-face))
        (let ((faces (face-attribute face :inherit nil)))
          (set-face-attribute
           face nil :inherit
           `(variable-pitch ,@(delq 'unspecified (if (listp faces) faces (list faces))))))))
    (defun aorst/treemacs-init-setup ()
      "Set treemacs theme, open treemacs, and expand all projects."
      (treemacs-load-theme "Atom")
      (treemacs)
      (aorst/treemacs-expand-all-projects))
    (defun aorst/treemacs-setup ()
      "Set treemacs buffer common settings."
      (setq tab-width 1
            mode-line-format nil
            line-spacing 5)
      (set-window-fringes nil 0 0 nil)
      (aorst/treemacs-variable-pitch-labels))
    (defun aorst/treemacs-setup-fringes ()
      "Set treemacs buffer fringes."
      (set-window-fringes nil 0 0 nil)
      (aorst/treemacs-variable-pitch-labels))
    (advice-add #'treemacs-select-window :after #'aorst/treemacs-setup-fringes)
    (defun aorst/treemacs-ignore (file _)
      (or (s-ends-with? ".elc" file)
          (s-ends-with? ".o" file)
          (s-ends-with? ".a" file)
          (string= file ".svn")))
    (add-to-list 'treemacs-ignored-file-predicates #'aorst/treemacs-ignore)
    (defun aorst/treemacs-setup-title ()
      (let ((format '((:eval (concat
                              (make-string
                               (let ((width (window-width)))
                                 (- (/ (if (= (% width 2) 0) width (1+ width)) 2) 5))
                               ?\ )
                              "Treemacs")))))
        (if (version<= emacs-version "27")
            (setq header-line-format format)
          (setq tab-line-format format)))
      (let ((bg (face-attribute 'default :background))
            (fg (face-attribute 'default :foreground))
            (face (if (version<= emacs-version "27")
                      'header-line
                    'tab-line)))
        (face-remap-add-relative face
                                 :box (list :line-width 7 :color bg)
                                 :background bg :foreground fg))))
  (setq treemacs-width 27
        treemacs-is-never-other-window t
        treemacs-space-between-root-nodes nil)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode nil))

(use-package eyebrowse
  :commands eyebrowse-mode
  :init (eyebrowse-mode t))

(use-package minions
  :commands minions-mode
  :init (minions-mode 1))

(use-package uniquify
  :ensure nil
  :config (setq uniquify-buffer-name-style 'forward))

(use-package term
  :ensure nil
  :bind (("C-`" . aorst/ansi-term-toggle)
         ("C-t" . aorst/ansi-term-focus))
  :config
  (defun aorst/ansi-term-toggle (&optional arg)
    "Toggle `ansi-term' window on and off with the same command."
    (interactive "P")
    (let* ((bufname " *ansi-term*")
           (window (get-buffer-window bufname)))
      (if window
          (ignore-errors (delete-window window))
        (let* ((win-side (if (symbolp arg)
                             (cons (split-window-below) 'bot)
                           (cons (split-window-right) 'right)))
               (window (car win-side))
               (side (cdr win-side)))
          (select-window window)
          (cond ((get-buffer bufname)
                 (switch-to-buffer bufname))
                (t (ansi-term "bash")
                   (rename-buffer bufname)))
          (set-window-dedicated-p window t)
          (set-window-parameter window 'no-delete-other-windows t)
          (set-window-parameter window 'window-side side)
          (set-window-parameter window 'no-other-window t)))))
  (defun aorst/ansi-term-focus (&optional arg)
    "Focus `ansi-term` or open one if there's none."
    (interactive "P")
    (let ((window (get-buffer-window " *ansi-term*")))
      (if window
          (select-window window)
        (aorst/ansi-term-toggle arg))))
  (defun aorst/autokill-when-no-processes (&rest _)
    "Kill buffer and its window when there's no processes left."
    (when (null (get-buffer-process (current-buffer)))
      (kill-buffer (current-buffer))))
  (advice-add 'term-handle-exit :after 'aorst/autokill-when-no-processes))

(use-package editorconfig
  :commands editorconfig-mode
  :config (editorconfig-mode 1))

(use-package flymake
  :ensure nil
  :config (setq flymake-fringe-indicator-position 'right-fringe))

(use-package hydra
  :commands (hydra-default-pre
             hydra-keyboard-quit
             hydra--call-interactively-remap-maybe
             hydra-show-hint
             hydra-set-transient-map)
  :bind (("<f5>" . hydra-zoom/body))
  :config (defhydra hydra-zoom (:hint nil)
            "Scale text"
            ("+" text-scale-increase "in")
            ("-" text-scale-decrease "out")
            ("0" (text-scale-set 0) "reset")))

(use-package geiser
  :hook (scheme-mode . geiser-mode)
  :config (setq geiser-active-implementations '(guile)
                geiser-default-implementation 'guile))

(use-package parinfer
  :commands (parinfer-mode
             parinfer-toggle-mode)
  :hook ((clojure-mode
          emacs-lisp-mode
          common-lisp-mode
          scheme-mode
          lisp-mode
          racket-mode) . parinfer-mode)
  :bind (:map parinfer-mode-map
              ("C-," . parinfer-toggle-mode))
  :config (setq parinfer-extensions
                '(defaults
                   pretty-parens
                   smart-tab
                   smart-yank)))

(use-package flx)

(use-package ivy
  :commands ivy-mode
  :bind (("C-x C-b" . ivy-switch-buffer)
         ("C-x b" . ivy-switch-buffer))
  :config
  (use-package counsel
    :commands (counsel-M-x
               counsel-find-file
               counsel-file-jump
               counsel-recentf
               counsel-rg
               counsel-describe-function
               counsel-describe-variable
               counsel-find-library)
    :config
    (when (executable-find "fd")
      (define-advice counsel-file-jump (:around (foo &optional initial-input initial-directory))
        (let ((find-program "fd")
              (counsel-file-jump-args (split-string "-L --type f --hidden")))
          (funcall foo))))
    (when (executable-find "rg")
      (setq counsel-rg-base-command
            "rg -S --no-heading --hidden --line-number --color never %s .")
      (setenv "FZF_DEFAULT_COMMAND"
              "rg --files --hidden --follow --no-ignore --no-messages --glob '!.git/*' --glob '!.svn/*'"))
    :bind (("M-x" . counsel-M-x)
           ("C-x C-f" . counsel-find-file)
           ("C-x f" . counsel-file-jump)
           ("C-x C-r" . counsel-recentf)
           ("C-h f" . counsel-describe-function)
           ("C-h v" . counsel-describe-variable)
           ("C-h l" . counsel-find-library)))
  (setq ivy-re-builders-alist '((t . ivy--regex-fuzzy))
        ivy-count-format ""
        ivy-display-style nil
        ivy-minibuffer-faces nil
        ivy-use-virtual-buffers t
        enable-recursive-minibuffers t)
  :init (ivy-mode 1))

(use-package company
  :commands global-company-mode
  :bind (:map company-active-map
              ("TAB" . company-complete-common-or-cycle)
              ("<tab>" . company-complete-common-or-cycle)
              ("<S-Tab>" . company-select-previous)
              ("<backtab>" . company-select-previous))
  :hook (after-init . global-company-mode)
  :config
  (use-package company-flx
    :config (company-flx-mode +1))
  (setq company-require-match 'never
        company-minimum-prefix-length 3
        company-tooltip-align-annotations t
        company-frontends
        '(company-pseudo-tooltip-unless-just-one-frontend
          company-preview-frontend
          company-echo-metadata-frontend))
  (setq company-backends '((company-capf :with company-yasnippet) company-files)))

(use-package undo-tree
  :commands global-undo-tree-mode
  :init (global-undo-tree-mode 1))

(use-package yasnippet
  :commands yas-reload-all
  :hook ((rust-mode
          c-mode-common
          racket-mode). yas-minor-mode)
  :config
  (use-package yasnippet-snippets)
  (yas-reload-all))

(use-package magit
  :bind (("<f12>" . magit-status))
  :config (setq magit-ediff-dwim-show-on-hunks t))

(use-package ediff
  :ensure nil
  :config
  (advice-add 'ediff-window-display-p :override #'ignore)
  (setq ediff-split-window-function 'split-window-horizontally))

(use-package multiple-cursors
  :commands (mc/cycle-backward
             mc/cycle-forward)
  :bind (("S-<mouse-1>" . mc/add-cursor-on-click)
         ("C-c m" . hydra-mc/body))
  :config
  (use-package mc-extras)
  (defhydra hydra-mc (:hint nil :color pink)
    "
^Select^                ^Discard^                    ^Move^
^──────^────────────────^───────^────────────────────^────^────────────
_M-s_: split lines      _M-SPC_: discard current     _&_: align
_s_:   select regexp    _b_:     discard blank lines _(_: cycle backward
_n_:   select next      _d_:     remove duplicated   _)_: cycle forward
_p_:   select previous  _q_:     exit                ^ ^
_C_:   select next line"
    ("M-s" mc/edit-ends-of-lines)
    ("s" mc/mark-all-in-region-regexp)
    ("n" mc/mark-next-like-this-word)
    ("p" mc/mark-previous-like-this-word)
    ("&" mc/vertical-align-with-space)
    ("(" mc/cycle-backward)
    (")" mc/cycle-forward)
    ("M-SPC" mc/remove-current-cursor)
    ("b" mc/remove-cursors-on-blank-lines)
    ("d" mc/remove-duplicated-cursors)
    ("C" mc/mark-next-lines)
    ("q" mc/remove-duplicated-cursors :exit t)))

(use-package expand-region
  :commands (er/expand-region
             er/mark-paragraph
             er/mark-inside-pairs
             er/mark-outside-pairs
             er/mark-inside-quotes
             er/mark-outside-quotes
             er/contract-region)
  :bind (("C-c e" . hydra-er/body))
  :config (defhydra hydra-er (:hint nil)
            "
^Expand^           ^Mark^
^──────^───────────^────^─────────────────
_e_: expand region _(_: inside pairs
_-_: reduce region _)_: around pairs
^ ^                _q_: inside quotes
^ ^                _Q_: around quotes
^ ^                _p_: paragraph"
            ("e" er/expand-region :color pink)
            ("-" er/contract-region :color pink)
            ("p" er/mark-paragraph)
            ("(" er/mark-inside-pairs)
            (")" er/mark-outside-pairs)
            ("q" er/mark-inside-quotes)
            ("Q" er/mark-outside-quotes)))

(use-package phi-search
  :bind (("C-s" . phi-search)
         ("C-r" . phi-search-backward))
  :config
  (set-face-attribute 'phi-search-selection-face nil :inherit 'isearch)
  (set-face-attribute 'phi-search-match-face nil :inherit 'region))

(when (and (or (executable-find "clangd")
               (executable-find "rls"))
           window-system)
  (use-package eglot
    :commands eglot-ensure
    :hook ((c-mode c++-mode rust-mode) . eglot-ensure)
    :compdef eglot--managed-mode-hook
    :company (company-capf company-files)
    :config
    (add-to-list 'eglot-server-programs '((c-mode c++-mode) "clangd"))
    (add-to-list 'eglot-ignored-server-capabilites :documentHighlightProvider)))

(use-package project
  :ensure nil
  :bind (("C-c p f" . project-find-file)
         ("C-c p r" . project-find-regexp))
  :config
  (defvar project-root-markers '("Cargo.toml" "compile_commands.json" "compile_flags.txt")
    "Files or directories that indicate the root of a project.")
  (defun aorst/project-find-root (path)
    "Tail-recursive search in PATH for root markers."
    (let* ((this-dir (file-name-as-directory (file-truename path)))
           (parent-dir (expand-file-name (concat this-dir "../")))
           (system-root-dir (expand-file-name "/")))
      (cond
       ((aorst/project-root-p this-dir) (cons 'transient this-dir))
       ((equal system-root-dir this-dir) nil)
       (t (aorst/project-find-root parent-dir)))))
  (defun aorst/project-root-p (path)
    "Check if current PATH has any of project root markers."
    (let ((results (mapcar (lambda (marker)
                             (file-exists-p (concat path marker)))
                           project-root-markers)))
      (eval `(or ,@ results))))
  (add-to-list 'project-find-functions #'aorst/project-find-root))

(use-package clang-format
  :after cc-mode
  :bind (:map c-mode-base-map
              ("C-c C-f" . clang-format-buffer)
              ("C-c C-S-f" . clang-format-region)))

(use-package gcmh
  :commands gcmh-mode
  :init (gcmh-mode 1))

(use-package vlf-setup
  :ensure vlf
  :config (setq vlf-application 'dont-ask))

(use-package imenu-list
  :defines imenu-list-idle-update-delay-time
  :bind (("<f9>" . imenu-list-smart-toggle)
         ("<f10>". imenu-list-show))
  :config
  (defun aorst/imenu-list-setup ()
    "Setings for imenu-list"
    (setq window-size-fixed 'width
          mode-line-format nil)
    (set-window-parameter (get-buffer-window (current-buffer)) 'no-other-window t))
  (advice-add 'imenu-list-smart-toggle :after-while #'aorst/imenu-list-setup)
  (setq imenu-list-idle-update-delay-time 0.1
        imenu-list-size 27
        imenu-list-focus-after-activation t))

(use-package dumb-jump
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g j" . dumb-jump-go))
  :config
  (setq dumb-jump-selector 'ivy)
  (when (executable-find "rg")
    (setq dumb-jump-force-searcher 'rg)))

(use-package iedit
  :bind ("C-q" . aorst/iedit-current-or-expand)
  :config
  (setq iedit-toggle-key-default "")
  (defun aorst/iedit-current-or-expand (&optional arg)
    "Select only current occurrence with `iedit-mode'.  Expand to
next occurrence if `iedit-mode' is already active."
    (interactive "P")
    (if (bound-and-true-p iedit-mode)
        (if (symbolp arg)
            (iedit-expand-down-to-occurrence)
          (iedit-expand-up-to-occurrence))
      (iedit-mode 1))))

(use-package server
  :ensure nil
  :config
  (unless (server-running-p)
    (server-start)))

(provide 'init)
;;; init.el ends here
