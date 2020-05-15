;;; remote-control.el --- Easy way to remotely control Emacs through DBus.  -*- lexical-binding: t -*-

;; Copyright (C) 2020 Yurii Hryhorenko

;; Author: Yurii Hryhorenko <yuragrig@ukr.net>
;; Homepage: http://github.com/rsauex/emacs-remote-control
;; Version: 1.0.0
;; Keywords: remote
;; Package-Requires: ((emacs "24.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;;; Commentary:

;; TODO

;;; Code:

(require 'dbus)

(defgroup remote-control nil
  "Remote control through DBus."
  :group 'emacs
  :link '(emacs-commentary-link "remote-control.el")
  :prefix "remote-control-")

(defcustom remote-control-dbus-service "org.emacs.remote"
  "DBus service for remote control."
  :group 'remote-control
  :type 'string)

(defcustom remote-control-dbus-path "/org/emacs/remote"
  "DBus path for remote control."
  :group 'remote-control
  :type 'string)

;;; Focus

(defvar remote-control--in-focus nil
  "Non-nil iff any frame is currently in focus.")

(defun remote-control-focused-p ()
  "Return non-nil iff any frame is currently in focus."
  remote-control--in-focus)

(add-hook 'focus-in-hook  (lambda () (setq remote-control--in-focus t)))
(add-hook 'focus-out-hook (lambda () (setq remote-control--in-focus nil)))

;; (defun remote-control-update-modes ()
;;   ;; major mode  - major-mode
;;   ;; minor modes - (mapcar #'car minor-mode-alist)
;;   ;; call update_modes() dbus method
;;   ;; TODO
;;   )

;; (add-hook 'focus-in-hook #'remote-control-update-modes)
;; (add-hook 'buffer-list-update-hook #'remote-control-update-modes)

(defun remote-control--command-name-to-signal (name)
  (replace-regexp-in-string "-" "" (capitalize (symbol-name name))))

(defun remote-control--full-interface-name (name)
  (concat remote-control-dbus-service "." name))

(defmacro define-remote-command (name args &rest body)
  "Declare new remote command NAME. BODY must start with ':interface <interface-short-name-string>'."
  (declare (indent defun))
  (unless (and (eq :interface (car body))
               (stringp (cadr body)))
    (error "First form in body of 'define-remote-command' must be ':interface'"))
  `(dbus-register-signal
    :session remote-control-dbus-service remote-control-dbus-path (remote-control--full-interface-name ,(cadr body))
    ,(remote-control--command-name-to-signal name)
    (lambda ,args
      (when (remote-control-focused-p)
        ,@(nthcdr 2 body)))))

;;; remote-control.el ends here
