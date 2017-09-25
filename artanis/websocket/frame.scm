;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2017
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

(define-module (artanis websocket frame)
  #:use-module (artanis utils)
  #:use-module (artanis server)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 match)
  #:use-module ((rnrs) #:select (define-record-type))
  #:use-module (rnrs bytevectors)
  #:export (received-closing-frame
            send-websocket-closing-frame

            make-websocket-frame
            websocket-frame?
            websocket-frame-parser
            websocket-frame-head1
            websocket-frame-head2
            websocket-frame-final-fragment?
            websocket-frame-opcode
            websocket-frame-type

            websocket-frame/client-final?
            websocket-frame/client-type
            websocket-frame/client-length
            websocket-frame/client-payload

            new-websocket-frame/client
            write-websocket-frame/client))

(define-record-type websocket-frame
  (fields
   parser
   payload-length
   payload-offset
   body))

(define-record-type websockt-frame/client
  (fields
   final?
   type
   length
   payload))

;;  %x0 denotes a continuation frame
(define (is-continue-frame? opcode) (= opcode #x0))
;;  %x1 denotes a text frame
(define (is-text-frame? opcode) (= opcode #x1))
;;  %x2 denotes a binary frame
(define (is-binary-frame? opcode) (= opcode #x2))
;;  %x3-7 are reserved for further non-control frames
(define (is-non-control-frame? opcode)
  (zero? (logand #x8 opcode)))
(define (is-control-frame? opcode)
  (not (is-non-control-frame? opcode)))
;;  %x8 denotes a connection close
(define (is-close-frame? opcode) (= opcode #x8))
;;  %x9 denotes a ping
(define (is-ping-frame? opcode) (= opcode #x9))
;;  %xA denotes a pong
(define (is-pong-frame? opcode) (= opcode #xa))
;;  %xB-F are reserved for further control frames
(define (is-reserved-frame? opcode)
  (and (> opcode #xb) (< opcode #xf)))

(define (is-masked-frame? head2)
  (not (zero? (logand #x80 head2))))

(define (is-final-frame? head1)
  (not (zero? (logand #x80 head1))))

(define (received-closing-frame port)
  #t)

(define (send-websocket-closing-frame port)

  ;; Make sure it's flushed before closing
  (force-output port))

(define *opcode-list*
  '(continuation         ; #x0
    text                 ; #x1
    binary               ; #x2
    non-control-reserved ; #x3
    non-control-reserved ; #x4
    non-control-reserved ; #x5
    non-control-reserved ; #x6
    non-control-reserved ; #x7
    close                ; #x9
    ping                 ; #xA
    pong                 ; #xB
    control-reserved     ; #xC
    control-reserved     ; #xD
    control-reserved     ; #xE
    control-reserved))   ; #xF

(define-syntax-rule (generate-opcode type)
  (list-index *opcode-list* type))

(define-syntax-rule (get-head1 bv)
  (bytevector-u8-ref bv 0))

(define-syntax-rule (get-head2 bv)
  (bytevector-u8-ref bv 1))

(define-syntax-rule (%get-opcode bv)
  (bytevector-u32-ref bv 4))

(define-syntax-rule (%get-type opcode)
  (assoc-ref *opcode-list* opcode))

(define-syntax-rule (%verify-type type)
  (cond
   ((eq? type 'non-control-reserved)
    (throw 'artanis-err 500 websocket-type
           "The opcode `#x~:@(~x~)' is reserved for non-control frame" opcode))
   ((eq? type 'control-reserved)
    (throw 'artanis-err 500 websocket-type
           "The opcode `#x~:@(~x~)' is reserved for control frame" opcode))
   (else type)))

(define-syntax-rule (%get-body bv payload-offset payload-length)
  (bv-copy/share bv payload-offset payload-length))

(::define (websocket-frame-head1 frame)
  (:anno: (websocket-frame) -> int)
  (get-head1 (websocket-frame-body frame)))

(::define (websocket-frame-head2 frame)
  (:anno: (websocket-frame) -> int)
  (get-head2 (websocket-frame-body frame)))

(::define (websocket-frame-final-fragment? frame)
  (:anno: (websocket-frame) -> boolean)
  (is-final-frame? (websocket-frame-head1 frame)))

(::define (websocket-frame-final? frame)
  (:anno: ))
(::define (websocket-frame-opcode frame)
  (:anno: (websocket-frame) -> int)
  (%get-opcode (websocket-frame-body frame)))

(::define (websocket-frame-type frame)
  (:anno: (websocket-frame) -> symbol)
  (%get-type (%get-opcode (websocket-frame-body frame))))

(::define (websocket-frame-body frame)
  (:anno: (websocket-frame) -> bytevector)
  (%get-body (websocket-frame-body frame)
             (websocket-frame-payload-offset frame)
             (websocket-frame-payload-length frame)))

(::define (websocket-frame-fin frame)
  (:anno: (websocket-frame) -> int)
  (if (websocket-frame-final-fragment? frame)
      #x80
      #x00))

;; NOTE: The frame will not be decoded or parsed into a record-type, on the contrary,
;;       it'll be kept as a binary frame read from client, and use bitwise operations for
;;       fetching the fields. This kind of `lazy' design will save much time on parsing
;;       unused fields each time, and eaiser for redirecting without any serialization.
;;       If users want to get certain field, Artanis provides APIs for fetching them. Users
;;       can decide how to parse the frames for efficiency.
(define (read-websocket-frame parser port)
  (define-syntax-rule (get-len control-frame? port)
    (cond
     ((< payload-len 126)
      ;; Yes, it's redundant, but I never trust the data from client
      payload-len)
     ((= payload-len 126)
      (bytevector-u16-ref (get-bytevector-n port 2) 0 'big))
     ((= payload-len 127)
      (if (not control-frame?)
          (bytevector-u64-ref (get-bytevector-n port 8) 0 'big)
          (throw 'artanis-err 1007 read-websocket-frame
                 "Invalid websocket frame, the control frame can't be segmented!")))
     (else (throw 'artanis-err 500 read-websocket-frame
                  "Invalid payload-len `~a'!" payload-len))))
  (define (payload-detect mask payload-len)
    (+ 1 ; head1
       1 ; head2
       (if (= payload-len 126) 2 8) ; real-len
       (if mask 4 0))) ; mask-len
  (define (decode-with-mask! payload len mask)
    (let lp ((i 0))
      (cond
       ((> i len) payload)
       (else
        (let ((masked (logxor (u8vector-ref payload i)
                              (u8vector-ref mask (modulo i 4)))))
          (u8vector-set! payload i masked)
          (lp (1+ i)))))))
  (define (cook-payload mask payload-offset payload-length bv)
    (let ((payload (%get-payload bv payload-offset)))
      (if mask
          (decode-with-mask! payload payload-length mask)
          payload)))
  (let* ((body (get-bytevector-all port))
         (head1 (get-head1 body))
         (head2 (get-head2 body))
         (control-frame? (is-control-frame? (%get-opcode body)))
         (payload-len (logand #x7f head1))
         (real-len (get-len body control-frame? payload-len))
         (mask (and (is-masked-frame? head2) (get-mask payload-len)))
         (payload-offset (detect-payload-offset mask payload-len))
         (payload (cook-payload mask payload-offset body)))
    (make-websocket-frame parser real-len payload-offset mask body)))

(::define (generate-head1 final? type)
  (:anno: (boolean symbol) -> int)
  (logior (if final? #x80 #x00)
          (generate-opcode type)))

(define 16bit-size (ash 1 16))
(define 64bit-size (ash 1 64))

;; NOTE: According to RFC-6455, A server MUST NOT mask any frames that it sends to
;;       the client. (From 5.1 Overview).
;; NOTE: If the length is larger than 16bit, then just speicify it to 127 then deal with
;;       the actual length in later extended length field.
(::define (generate-head2 len)
  (:anno: (+int) -> +int)
  (cond
   ((< len 126) len) ; payload length less than 126 bytes
   ((< len 16bit-size) 126) ; extended 16bit payload length
   ((< len 64bit-size) 127) ; extended 64bit payload length
   (else (throw 'artanis-err 500 generate-head2
                "The payload size `~a' excceded 64bit!" len))))

(::define (write-websocket-frame/client res frame)
  (:anno: (response websocket-frame/client) -> ANY)
  (define (write-payload-size port len)
    (if (and (> len 126) (< len 16bit-size))
        (put-bytevector port (uint-list->bytevector (list len) 'big 2))
        (put-bytevector port (uint-list->bytevector (list len) 'big 8))))
  (let* ((final? (websocket-frame/client-final? frame))
         (type (websocket-frame/client-type frame))
         (len (websocket-frame/client-length frame))
         (payload (websocket-frame/client-payload frame))
         (port (response-port res))
         (head1 (generate-head1 final? type))
         (head2 (generate-head2 len)))
    (put-u8 port head1)
    (put-u8 port head2)
    (write-payload-size port head2) ; head2 is actually the size since mask must be 0
    (write-response-body res (websocket-frame/client-payload frame))))

;; NOTE: A better design is not to split then store fields to record-type,
;;       we just need to parse the frame and store the offset.
;; NOTE: It's better to delay preprocessing to the time the payload is needed.
;;       And store the preprocessor to the frame (record-type).
;; NOTE: Return bytevector
(::define (new-websocket-frame/client type final? payload)
  (:anno: (symbol boolean bytevector) -> websocket-frame/client)
  (let ((payload-len (bytevector-length payload)))
    (make-websocket-frame/client
     final?
     type
     payload-len
     payload)))
