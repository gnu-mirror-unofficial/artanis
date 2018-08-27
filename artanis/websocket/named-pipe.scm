;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2018
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

(define-module (artanis websocket named-pipe)
  #:use-module (artanis utils)
  #:use-module (artanis irregex)
  #:use-module (artanis route)
  #:use-module (artanis websocket frame)
  #:use-module (artanis server)
  #:use-module (artanis server server-context)
  #:use-module ((ice-9 iconv) #:select (string->bytevector))
  #:use-module ((rnrs) #:select (bytevector? define-record-type))
  #:export (register-websocket-pipe!
            send-to-websocket-named-pipe
            named-pipe-subscribe
            remove-named-pipe-if-the-connection-is-websocket!))

;; NOTE: named-pipe and client is 1:1 relation, we also make a table
;;       for getting name from client. It's worth since every client can
;;       register a named-pipe, and there're too many named-pipe to be
;;       traversed to close when the client refresh the page.
(define *client-to-named-pipe* (make-hash-table))
(define *websocket-named-pipe* (make-hash-table))

(define-record-type named-pipe
  (fields name client task-queue))

(define (new-named-pipe name client)
  (make-named-pipe name client (new-queue)))

(define (client->pipe-name client)
  (hashq-ref *client-to-named-pipe* client))

(define (remove-named-pipe-if-the-connection-is-websocket! client)
  (let ((name (client->pipe-name client)))
    (when name
      (DEBUG "Removing named-pipe `~a' since client is closed......" name)
      (hash-remove! *websocket-named-pipe* name)
      (hashq-remove! *client-to-named-pipe* client)
      (DEBUG "Done~%"))))

(define (get-named-pipe name)
  (hash-ref *websocket-named-pipe* name))

(define (get-pipe-client name)
  (and=> (get-named-pipe name) named-pipe-client))

(define (get-pipe-task-queue name)
  (and=> (get-named-pipe name) named-pipe-task-queue))

(define *named-pipe-re*
  (string->sre "artanis_named_pipe=(.*)"))

(define (detect-pipe-name req)
  (let ((m (irregex-match *named-pipe-re* (uri-query (request-uri req)))))
    (and m
         (irregex-match-substring m 1))))

(define (register-websocket-pipe! req client)
  (let ((name (detect-pipe-name req)))
    (cond
     (name
      (hash-set! *websocket-named-pipe* name (new-named-pipe name client))
      (hash-set! *client-to-named-pipe* client name))
     (else
      (DEBUG "The websocket is not an artanis-named-pipe, don't register it!~%")))))

(define (send-to-websocket-named-pipe name data)
  (let ((client (get-pipe-client name))
        (frame (new-websocket-frame/client
                'text #t
                (cond
                 ((string? data) (string->bytevector data "iso-8859-1"))
                 ((bytevector? data) data)
                 (else (throw 'artanis-err 500 send-to-websocket-named-pipe
                              "Wrong type of websocket data, should be string or bv `~a'"
                              data))))))
    (cond
     (client
      (let ((task-queue (get-pipe-task-queue name)))
        ;; NOTE: We can't just send the data to the named-pipe, since it's possible to have
        ;;       race conditions. If data-1 were blocked in transmission, and data-2 were
        ;;       coming then the operation would be undetermined when the connection is
        ;;       awakend.
        ;; NOTE: The task queue will be handled in named-pipe-event-loop to send the data
        ;;       one by one.
        (when task-queue
          (queue-in! task-queue
                     (lambda ()
                       (parameterize ((current-client client))
                         (write-websocket-frame/client (client-sockport client) frame))))
          (oneshot-mention! client))))
     (else
      (throw 'artanis-err 400 send-to-websocket-named-pipe
             "Invalid pipe name `~a' or it's closed by client!" name)))))

(define (named-pipe-subscribe rc)
  (let* ((name (detect-pipe-name (rc-req rc)))
         (task-queue (get-pipe-task-queue name)))
    (let lp ()
      (cond
       ((not task-queue)
        (throw 'artanis-err 400 named-pipe-subscribe
               "Named-pipe `~a' was closed, we drop this connection!" name))
       ((queue-empty? task-queue)
        (DEBUG "Named-pipe: task queue is empty, we scheduled!~%")
        (break-task)
        (lp))
       (else
        (let ((t (queue-out! task-queue)))
          (DEBUG "Named-pipe: run a task ~a" t)
          (t)
          (break-task)
          (lp)))))))
