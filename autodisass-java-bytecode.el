;;; autodisass-java-bytecode.el --- Automatically disassemble Java bytecode

;; Copyright (C) 2014, George Balatsouras
;;
;; Author: George Balatsouras <gbalats(at)gmail(dot)com>
;; Maintainer: Ivan Tudiyarov <eig114(at)gmail(dot)com>
;; Created: 22 Jun 2014
;; Version: 1.3.1
;; Keywords: convenience, data, files
;;
;; This file is NOT part of Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;; To use, save `autodisass-java-bytecode.el' to a directory in your
;; load-path and add the following to your `.emacs'.
;;
;; (require 'autodisass-java-bytecode)


;;; Commentary:

;; This package enables automatic disassembly of Java bytecode.
;;
;; It was inspired by a blog post of Christopher Wellons:
;;    https://nullprogram.com/blog/2012/08/01/
;;
;; Disassembly can happen in two cases:
;; (a) when opening a Java .class file
;; (b) when disassembling a .class file inside a jar
;;
;; In any case, `javap' or another disassembler/decompiler must be
;; installed in the system for this extension to have any effect,
;; since that is the tool that actually performs the disassembly.

;;; Code:


(require 'ad-javap-mode)

(defconst autodisass-java-bytecode-version "1.3.1")

(defgroup autodisass-java-bytecode nil
  "Automatic disassembly of Java bytecode."
  :tag    "Java Bytecode Disassembly"
  :prefix "ad-java-bytecode-"
  :group  'autodisass)


(defconst ad-java-bytecode-regexp "\\.class$"
  "Regular expressions that matches Java bytecode files.")


(defcustom ad-java-bytecode-disassembler "javap"
  "Return the name of the disassembler command.
If the command is not on your path, you may specify a fully
qualified path to it.  The command should accept the input file
name as its last argument and print the disassembled file on the
output stream."
  :tag "Disassembler command"
  :group 'autodisass-java-bytecode
  :type 'string)

(defcustom ad-java-bytecode-parameters
  '("-private" "-verbose")
  "Extra parameters for the disassembler process."
  :tag "Command line options"
  :group 'autodisass-java-bytecode
  :type '(repeat string))

(defcustom ad-java-bytecode-prompt t
  "Prompt before disassembling. If false, will automatically disassemble."
  :tag "Prompt"
  :group 'autodisass-java-bytecode
  :type 'boolean)

(defcustom ad-java-bytecode-arg-formatter
  #'ad-java-javap-format-args
  "Function to format command line arguments for disassembler"
  :tag "Command line options formatter"
  :group 'autodisass-java-bytecode
  :type 'function)

(defcustom ad-java-disassembler-mode
  #'ad-javap-mode
  "Function to set mode in disassembled class buffer"
  :tag "Mode setter"
  :group 'autodisass-java-bytecode
  :type 'function)


;; javap-specific
(defvar ad-java--javap-exec-history (list "javap"))
(defvar ad-java--javap-params-history (list (format "%S" '("-private" "-verbose"))))

(defun ad-java-javap-class-name (class-file)
  "Return the corresponding CLASS-NAME of a CLASS-FILE."
  (replace-regexp-in-string
   "/" "." (file-name-sans-extension class-file)))

(defun ad-java-javap-format-args (class-file &optional jar-file)
  (let ((class-name  (ad-java-javap-class-name class-file))
        (class-path  (or jar-file (file-name-directory class-file))))
    (append ad-java-bytecode-parameters
            (list "-classpath" class-path
                  (if jar-file class-name class-file)))))


;;;###autoload
(defun ad-java-disassembler-setup-javap (javap-exec javap-params)
  "Setup autodisass java mode to use javap as disassembler"
  (interactive (list (read-from-minibuffer "javap command: " (car ad-java--javap-exec-history)
                                           nil nil
                                           'ad-java--javap-exec-history)
                     (read-from-minibuffer "javap command arglist: " (car ad-java--javap-params-history)
                                           nil t
                                           'ad-java--javap-params-history
                                           "nil")))
  (setq ad-java-bytecode-disassembler javap-exec
        ad-java-disassembler-arg-formatter #'ad-java-javap-format-args
        ad-java-disassembler-mode #'ad-javap-mode
        ad-java-bytecode-parameters javap-params))

;; cfr-specific
(defvar ad-java--cfr-exec-history '("java"))
(defvar ad-java--cfr-params-history '("(\"-jar\" \"cfr.jar\")"))

(defun ad-java-cfr-normalize-class-name (class-name)
  "Return the corresponding CLASS-NAME of a CLASS-FILE."
  ;; replace slashes with dots, remove dollar-suffix and extension
  (replace-regexp-in-string
   "\\(\\$.*\\)?\\.class$" ""
   (string-replace
    "/" "."
    class-file)))

(defun ad-java-cfr-format-args (class-file &optional jar-file)
  (append (if jar-file
              ;; jarfilter accepts regex, but we need to match classname exactly
              (list jar-file "--jarfilter" (concat "^"
                                                   (regexp-quote (ad-java-cfr-normalize-class-name class-file))
                                                   "$"))
            (list class-file))
          ad-java-bytecode-parameters))

;;;###autoload
(defun ad-java-disassembler-setup-cfr (cfr-exec cfr-params)
  "Setup autodisass java mode to use cfr as disassembler"
  (interactive (list (read-from-minibuffer "cfr executable: " (car ad-java--cfr-exec-history)
                                           nil nil
                                           'ad-java--cfr-exec-history)
                     (read-from-minibuffer "cfr command arglist: " (car ad-java--cfr-params-history)
                                           nil t
                                           'ad-java--cfr-params-history
                                           "nil")))
  (setq ad-java-bytecode-disassembler cfr-exec
        ad-java-disassembler-arg-formatter #'ad-java-cfr-format-args
        ad-java-disassembler-mode #'java-mode
        ad-java-bytecode-parameters cfr-params))

;; fernflower-specific
;;TODO
;; The problem with fernflower is that it refuses to output to stdout,
;; and jar files are decompiled to jar files with sources replacing
;; classes, so normal approach is not applicable.

(defun ad-java-bytecode-disassemble-p (file)
  "Return t if automatic disassembly should be performed for FILE."
  (and (string-match ad-java-bytecode-regexp file)
       (executable-find ad-java-bytecode-disassembler)
       (or (not ad-java-bytecode-prompt)
           (y-or-n-p (format "Disassemble %s using %s? " file
                             ad-java-bytecode-disassembler)))))


(defun ad-java-bytecode-buffer (class-file &optional jar-file)
  (let ((orig-buffer-name      (buffer-name))
        (orig-buffer-file-name (buffer-file-name)))
    ;; kill previous buffer
    (kill-buffer orig-buffer-name)
    ;; create and select new buffer with disassembled contents
    (switch-to-buffer (generate-new-buffer orig-buffer-name))
    (message "Disassembling %s" class-file)
    ;; disassemble .class file
    (apply 'call-process ad-java-bytecode-disassembler nil t nil
           (funcall ad-java-disassembler-arg-formatter class-file jar-file))
    ;; set some properties
    (set-visited-file-name nil)
    (setq buffer-file-name orig-buffer-file-name)
    (setq buffer-read-only t)           ; mark as modified
    (set-buffer-modified-p nil)         ; mark as read-only
    (goto-char (point-min))             ; jump to top
    (funcall ad-java-disassembler-mode) ; set correct mode
    (message "Disassembled %s" class-file)
    (current-buffer)))


;; Add hook for automatically disassembling .class files
(add-hook 'find-file-hook
          (lambda () (let ((class-file (buffer-file-name)))
                       (when (ad-java-bytecode-disassemble-p class-file)
                         (ad-java-bytecode-buffer class-file)))))

;; Add hook for automatically disassembling .class files inside jars

(add-hook 'archive-extract-hook
          (lambda ()
            (let* ((components (split-string (buffer-file-name) ":"))
                   (jar-file   (car components))
                   (class-file (cadr components)))
              (when (ad-java-bytecode-disassemble-p class-file)
                (ad-java-bytecode-buffer class-file jar-file)))))


(provide 'autodisass-java-bytecode)

;;; autodisass-java-bytecode.el ends here
