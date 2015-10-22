;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2015
;;      "Mu Lei" known as "NalaGinrut" <NalaGinrut@gmail.com>
;;  Artanis is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License and GNU
;;  Lesser General Public License published by the Free Software
;;  Foundation, either version 3 of the License, or (at your option)
;;  any later version.

;;  Artanis is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License and GNU Lesser General Public License
;;  for more details.

;;  You should have received a copy of the GNU General Public License
;;  and GNU Lesser General Public License along with this program.
;;  If not, see <http://www.gnu.org/licenses/>.

(define-module (artanis commands work)
  #:use-module (artanis utils)
  #:use-module (artanis env)
  #:use-module (artanis commands)
  #:use-module (artanis artanis)
  #:use-module (artanis config)
  #:use-module (artanis mvc controller)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match))

;; `art work' command is used to run the server and make the site/app work
;; for clients/browsers.

(define %summary "Run the server and make the site/app work.")

(define option-spec
  '((help (value #f))
    (config (single-char #\c) (value #t))
    (port (single-char #\p) (value #t))
    (usedb (single-char #\d) (value #f))
    (dbd (single-char #\b) (value #t))
    (name (single-char #\n) (value #t))
    (host (single-char #\h) (value #t))
    (user (single-char #\u) (value #t))
    (passwd (single-char #\w) (value #t))
    (debug (single-char #\g) (value #f))
    ;; NOTE: this is used for new server-core in the future,
    ;;       but now it's just useless.
    (server (single-char #\s) (value #t))))

(define (try-load-entry)
  (let ((entry (string-append (current-toplevel) "/" *artanis-entry*)))
    (load entry)))

(define (try-load-app)
  ;;(load-app-models)
  (load-app-controllers)
  ;;(load-app-views)
  ;;(load-app-apis)
  )

(define (register-rules)
  (register-controllers)
  (dump-route-from-cache))

(define *component-meta-table*
  `((controller . ,*controllers-table*)))
(define (load-compent-rules component)
  (define rf (string-append (current-toplevel) "/.route"))
  (define (-> k)
    (module-ref (resolve-module '(artanis artanis)) k))
  (when (not (file-exists? rf))
    (error load-rules (format #f "BUG: ~a wasn't generated successfully!" rf)))
  (call-with-input-file rf
    (lambda (port)
      (let lp((r (read port)))
        (cond
         ((eof-object? r) #t)
         (else
          (let ((method (car r))
                (rule (cadr r))
                (table (assq-ref *component-meta-table* component)))
            (apply (-> method) rule (hash-ref table rule))
            (lp (read port)))))))))

(define (load-rules)
  (load-compent-rules 'controller))

(define (clean-stuffs)
  (define toplevel (current-toplevel))
  (define route-cache (format #f "~a/tmp/cache/route.cache" toplevel))
  (define route (format #f "~a/.route" toplevel))
  (define-syntax-rule (clean-it f)
    (when (file-exists? f) (delete-file f)))
  (clean-it route-cache)
  (clean-it route))

(define (work . args)
  (let ((options (if (null? args) '() (getopt-long args option-spec))))
    (define-syntax-rule (->opt k) (option-ref options k #f))
    (define-syntax-rule (get-conf-file)
      (or (->opt 'config) (gen-local-conf-file)))
    (cond
     ((->opt 'help) (show-help))
     (else
      (clean-stuffs)
      (add-to-load-path (current-toplevel))
      (try-load-entry)
      (try-load-app)
      (register-rules)
      (load-rules)
      (parameterize ((current-conf-file (get-conf-file)))
        (run #:host (->opt 'host)
             #:port (and=> (->opt 'port) string->number)
             #:debug (->opt 'debug)
             #:use-db? (->opt 'usedb)
             #:dbd (and=> (->opt 'dbd) string->symbol)
             #:db-name (->opt 'name)
             #:db-username (->opt 'user)
             #:db-passwd (->opt 'passwd)))))))

(define help-str
"
Usage:
  art work [options]

Options:
  -c, [--config=CONFIG]          # Specify config file
                                   Default: ./artanis.conf
                                            if no, /etc/artanis/artanis.conf
  -h, [--host=HOST]              # Specify the network host
                                   Default: 0.0.0.0
  -d, [--usedb]                  # Whether to use Database
                                   Default: false
  -b, [--dbd=DBD]                # Specify DBD, mysql/postgresql/sqlit3
                                   Default: mysql
  -n, [--name=DATABASE_NAME]     # Database name
                                   Default: artanis
  -w, [--passwd=PASSWD]          # Database password
                                   Default: none
  -u, [--user=USER]              # Database user name
                                   Default: root
  -p, [--port=PORT]              # Specify listenning port
                                   Default: 3000
  -g, [--debug]                  # Debug mode
                                   Default: disable
  -s, [--server=SERVER]          # Specify server core
                                   Default: inner (Guile built-in server)
  --help                         # Show this screen
")

(define (show-help)
  (display announce-head)
  (display help-str)
  (display announce-foot))

(define main work)
