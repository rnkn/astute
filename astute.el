;;; astute.el --- A minor mode to redisplay `smart' typography  -*- lexical-binding: t; -*-

;; Copyright (C) 2021-2024  Paul W. Rankin

;; Author: Paul W. Rankin <rnkn@rnkn.xyz>
;; Keywords: faces, wp
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1"))
;; URL: https://github.com/rnkn/astute

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Astute
;; ======

;; A simple Emacs minor mode to redisplay ASCII punctuation as typographic
;; (or "smart") punctuation without altering file contents.

;; The following characters are redisplayed:

;; - '' -> ‘’ (single quotes)
;; - "" -> “” (double quotes)
;; - -- -> – (en dash)
;; - --- -> — (em dash)

;; Left/right quote is based on word boundary, not correct grammar. This is
;; intentional.

;;; Code:

(defgroup astute ()
  "A minor mode to redisplay ``smart'' typography."
  :prefix "astute-"
  :group 'text)

(defvar astute-double-quote-open-regexp
  "\\(\"\\)[[:alnum:][:punct:]]")

(defvar astute-double-quote-close-regexp
  "[[:alnum:][:punct:]]\\(\"\\)")

(defvar astute-single-quote-open-regexp
  "\\('\\)[[:alnum:][:punct:]]")

(defvar astute-single-quote-close-regexp
  "[[:alnum:][:punct:]]\\('\\)")

(defvar astute-single-quote-inner-regexp
  "[:alnum:]\\('\\)[:alnum:]")

(defvar astute-en-dash-regexp
  "\\(--\\)[^-]")

(defvar astute-em-dash-regexp
  "\\(---\\)[^-]")

(defcustom astute-lighter
  (format " %sAs%s" (char-to-string 8220) (char-to-string 8221))
  "Mode-line indicator for `astute-mode'."
  :type 'string
  :safe 'stringp)

(defcustom astute-transform-list
  '(single-quote double-quote en-dash em-dash)
  "List of characters to typographically transform."
  :type '(set (const :tag "Single Quotes" single-quote)
              (const :tag "Double Quotes" double-quote)
              (const :tag "En Dashes"     en-dash)
              (const :tag "Em Dashes"     em-dash))
  :safe 'listp)

(defcustom astute-prefix-single-quote-exceptions
  '("bout"
    "em"
    "cause"
    "round"
    "twas"
    "tis")
  "List of regular expressions that should be prefixed by a closing quote."
  :type '(repeat string))

(defvar-local astute--keywords nil)

(defun astute-case-insensitize (string)
  "Return a case-insensitive regular expression for STRING."
  (mapconcat (lambda (c)
               (let ((l (downcase c)) (u (upcase c)))
                 (if (eq l u)
                     (string l)
                   (format "[%c%c]" u l))))
             string))

(defun astute-init-font-lock ()
  "Return a new list of `font-lock-keywords'."
  (delq nil
        (list
         (when (memq 'single-quote astute-transform-list)
           (cons astute-single-quote-open-regexp
                 `((1 '(face nil display ,(char-to-string 8216))))))
         (when (memq 'single-quote astute-transform-list)
           (cons astute-single-quote-inner-regexp
                 `((1 '(face nil display ,(char-to-string 8217))))))
         (when (memq 'single-quote astute-transform-list)
           (cons (string-join
                  (cons astute-single-quote-close-regexp
                        (mapcar
                         (lambda (r)
                           (concat "\\(?1:'\\)" r))
                         (cons "[0-9][0-9]s?"
                               (mapcar 'astute-case-insensitize
                                       astute-prefix-single-quote-exceptions))))
                  "\\|")
                 `((1 '(face nil display ,(char-to-string 8217))))))
         (when (memq 'double-quote astute-transform-list)
           (cons astute-double-quote-open-regexp
                 `((1 '(face nil display ,(char-to-string 8220))))))
         (when (memq 'double-quote astute-transform-list)
           (cons astute-double-quote-close-regexp
                 `((1 '(face nil display ,(char-to-string 8221))))))
         (when (memq 'en-dash astute-transform-list)
           (cons astute-en-dash-regexp
                 `((1 '(face nil display ,(char-to-string 8211))))))
         (when (memq 'em-dash astute-transform-list)
           (cons astute-em-dash-regexp
                 `((1 '(face nil display ,(char-to-string 8212)))))))))

;;;###autoload
(define-minor-mode astute-mode
  "Redisplay `smart' typography."
  :lighter astute-lighter
  (when astute--keywords
    (font-lock-remove-keywords nil astute--keywords)
    (setq astute--keywords nil))
  (if astute-mode
      (when (setq astute--keywords (astute-init-font-lock))
        (font-lock-add-keywords nil astute--keywords t)
        (font-lock-flush))
    (save-excursion
      (save-restriction)
      (widen)
      (goto-char (point-min))
      (with-silent-modifications
        (let (match)
          (while (setq match (text-property-search-forward 'display))
            (when (seq-some
                   (lambda (char)
                     (= char (string-to-char (prop-match-value match))))
                   '(8216 8217 8220 8221 8211 8212))
              (remove-text-properties (prop-match-beginning match)
                                      (prop-match-end match)
                                      '(display)))))))))

(provide 'astute)

;; Local Variables:
;; coding: utf-8
;; fill-column: 80
;; indent-tabs-mode: nil
;; require-final-newline: t
;; sentence-end-double-space: nil
;; End:

;;; astute.el ends here
