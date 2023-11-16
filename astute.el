;;; astute.el --- A minor mode to redisplay smart typography  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Paul W. Rankin

;; Author: Paul W. Rankin <pwr@bydasein.com>
;; Keywords: faces, wp

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

;;

;;; Code:

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
  "Mode-line indicator for `astute-mode'.")

(defcustom astute-transform-list
  '(single-quote double-quote en-dash em-dash)
  "List of characters to typographically transform."
  :type '(set (const :tag "Single Quotes" single-quote)
              (const :tag "Double Quotes" double-quote)
              (const :tag "En Dashes"     en-dash)
              (const :tag "Em Dashes"     em-dash)))

(defcustom astute-double-space-sentences
  nil
  "When non-nil, display sentences as double-spaced."
  :type 'boolean)

;; :set (lambda (symbol value)
;;       (set-default symbol value)
;;       (mapc (lambda (buffer)
;;                (with-current-buffer buffer
;;                  (when astute-mode (font-lock-flush))))
;;              (buffer-list))))

(defvar-local astute--keywords nil)

(defun astute-init-font-lock ()
  (list
   (when (memq 'single-quote astute-transform-list)
     (cons astute-single-quote-open-regexp
           `((1 '(face nil display ,(char-to-string 8216))))))
   (when (memq 'single-quote astute-transform-list)
     (cons astute-single-quote-close-regexp
           `((1 '(face nil display ,(char-to-string 8217))))))
   (when (memq 'single-quote astute-transform-list)
     (cons astute-single-quote-inner-regexp
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
           `((1 '(face nil display ,(char-to-string 8212))))))
   (when astute-double-space-sentences
     (cons (sentence-end)
           `((2 '(face nil display "  ")))))))

;;;###autoload
(define-minor-mode astute-mode
  "Redisplay smart typography."
  :lighter astute-lighter
  (when astute--keywords
    (font-lock-remove-keywords nil astute--keywords)
    (setq astute--keywords nil))
  (if astute-mode
      (when (setq astute--keywords (astute-init-font-lock))
        (font-lock-add-keywords nil astute--keywords t)
        (font-lock-flush))
    (with-silent-modifications
      (remove-text-properties (point-min) (point-max) '(display)))))

(provide 'astute)

;; Local Variables:
;; coding: utf-8
;; fill-column: 80
;; indent-tabs-mode: nil
;; require-final-newline: t
;; sentence-end-double-space: nil
;; End:

;;; astute.el ends here
