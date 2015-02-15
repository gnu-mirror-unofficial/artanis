;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2013,2014,2015
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

(define-module (artanis mime)
  #:export (mime-guess mime-check))

(define mime-list
  `((application/andrew-inset (ez))
    (application/annodex (anx))
    (application/atom+xml (atom))
    (application/atomcat+xml (atomcat))
    (application/atomserv+xml (atomsrv))
    (application/bbolin (lin))
    (application/cap (cap pcap))
    (application/cu-seeme (cu))
    (application/davmount+xml (davmount))
    (application/dsptype (tsp))
    (application/ecmascript (es))
    (application/futuresplash (spl))
    (application/hta (hta))
    (application/java-archive (jar))
    (application/java-serialized-object (ser))
    (application/java-vm (class))
    (application/javascript (js))
    (application/m3g (m3g))
    (application/mac-binhex40 (hqx))
    (application/mac-compactpro (cpt))
    (application/mathematica (nb nbp))
    (application/msaccess (mdb))
    (application/msword (doc dot))
    (application/mxf (mxf))
    (application/octet-stream (bin))
    (application/oda (oda))
    (application/ogg (ogx))
    (application/pdf (pdf))
    (application/pgp-keys (key))
    (application/pgp-signature (pgp))
    (application/pics-rules (prf))
    (application/postscript (ps ai eps epsi epsf eps2 eps3))
    (application/rar (rar))
    (application/rdf+xml (rdf))
    (application/rss+xml (rss))
    (application/rtf (rtf))
    (application/smil (smi smil))
    (application/xhtml+xml (xhtml xht))
    (application/xml (xml xsl xsd))
    (application/xspf+xml (xspf))
    (application/zip (zip))
    (application/vnd.android.package-archive (apk))
    (application/vnd.cinderella (cdy))
    (application/vnd.google-earth.kml+xml (kml))
    (application/vnd.google-earth.kmz (kmz))
    (application/vnd.mozilla.xul+xml (xul))
    (application/vnd.ms-excel (xls xlb xlt))
    (application/vnd.ms-pki.seccat (cat))
    (application/vnd.ms-pki.stl (stl))
    (application/vnd.ms-powerpoint (ppt pps))
    (application/vnd.oasis.opendocument.chart (odc))
    (application/vnd.oasis.opendocument.database (odb))
    (application/vnd.oasis.opendocument.formula (odf))
    (application/vnd.oasis.opendocument.graphics (odg))
    (application/vnd.oasis.opendocument.graphics-template (otg))
    (application/vnd.oasis.opendocument.image (odi))
    (application/vnd.oasis.opendocument.presentation (odp))
    (application/vnd.oasis.opendocument.presentation-template (otp))
    (application/vnd.oasis.opendocument.spreadsheet (ods))
    (application/vnd.oasis.opendocument.spreadsheet-template (ots))
    (application/vnd.oasis.opendocument.text (odt))
    (application/vnd.oasis.opendocument.text-master (odm))
    (application/vnd.oasis.opendocument.text-template (ott))
    (application/vnd.oasis.opendocument.text-web (oth))
    (application/vnd.openxmlformats-officedocument.spreadsheetml.sheet (xlsx))
    (application/vnd.openxmlformats-officedocument.spreadsheetml.template (xltx))
    (application/vnd.openxmlformats-officedocument.presentationml.presentation (pptx))
    (application/vnd.openxmlformats-officedocument.presentationml.slideshow (ppsx))
    (application/vnd.openxmlformats-officedocument.presentationml.template (potx))
    (application/vnd.openxmlformats-officedocument.wordprocessingml.document (docx))
    (application/vnd.openxmlformats-officedocument.wordprocessingml.template (dotx))
    (application/vnd.rim.cod (cod))
    (application/vnd.smaf (mmf))
    (application/vnd.stardivision.calc (sdc))
    (application/vnd.stardivision.chart (sds))
    (application/vnd.stardivision.draw (sda))
    (application/vnd.stardivision.impress (sdd))
    (application/vnd.stardivision.math (sdf))
    (application/vnd.stardivision.writer (sdw))
    (application/vnd.stardivision.writer-global (sgl))
    (application/vnd.sun.xml.calc (sxc))
    (application/vnd.sun.xml.calc.template (stc))
    (application/vnd.sun.xml.draw (sxd))
    (application/vnd.sun.xml.draw.template (std))
    (application/vnd.sun.xml.impress (sxi))
    (application/vnd.sun.xml.impress.template (sti))
    (application/vnd.sun.xml.math (sxm))
    (application/vnd.sun.xml.writer (sxw))
    (application/vnd.sun.xml.writer.global (sxg))
    (application/vnd.sun.xml.writer.template (stw))
    (application/vnd.symbian.install (sis))
    (application/vnd.visio (vsd))
    (application/vnd.wap.wbxml (wbxml))
    (application/vnd.wap.wmlc (wmlc))
    (application/vnd.wap.wmlscriptc (wmlsc))
    (application/vnd.wordperfect (wpd))
    (application/vnd.wordperfect5.1 (wp5))
    (application/x-123 (wk))
    (application/x-7z-compressed (7z))
    (application/x-bzip2 (bz2))
    (application/x-gzip (gz))
    (application/x-abiword (abw))
    (application/x-apple-diskimage (dmg))
    (application/x-bcpio (bcpio))
    (application/x-bittorrent (torrent))
    (application/x-cab (cab))
    (application/x-cbr (cbr))
    (application/x-cbz (cbz))
    (application/x-cdf (cdf cda))
    (application/x-cdlink (vcd))
    (application/x-chess-pgn (pgn))
    (application/x-cpio (cpio))
    (application/x-csh (csh))
    (application/x-debian-package (deb udeb))
    (application/x-director (dcr dir dxr))
    (application/x-dms (dms))
    (application/x-doom (wad))
    (application/x-dvi (dvi))
    (application/x-httpd-eruby (rhtml))
    (application/x-font (pfa pfb gsf pcf pcf.Z))
    (application/x-freemind (mm))
    (application/x-futuresplash (spl))
    (application/x-gnumeric (gnumeric))
    (application/x-go-sgf (sgf))
    (application/x-graphing-calculator (gcf))
    (application/x-gtar (gtar tgz taz tar.gz tar.bz2 tbz2))
    (application/x-hdf (hdf))
    (application/x-httpd-php (phtml pht php))
    (application/x-httpd-php-source (phps))
    (application/x-httpd-php3 (php3))
    (application/x-httpd-php3-preprocessed (php3p))
    (application/x-httpd-php4 (php4))
    (application/x-httpd-php5 (php5))
    (application/x-ica (ica))
    (application/x-info (info))
    (application/x-internet-signup (ins isp))
    (application/x-iphone (iii))
    (application/x-iso9660-image (iso))
    (application/x-jam (jam))
    (application/x-java-jnlp-file (jnlp))
    (application/x-jmol (jmz))
    (application/x-kchart (chrt))
    (application/x-killustrator (kil))
    (application/x-koan (skp skd skt skm))
    (application/x-kpresenter (kpr kpt))
    (application/x-kspread (ksp))
    (application/x-kword (kwd kwt))
    (application/x-latex (latex))
    (application/x-lha (lha))
    (application/x-lyx (lyx))
    (application/x-lzh (lzh))
    (application/x-lzx (lzx))
    (application/x-maker (frm maker frame fm fb book fbdoc))
    (application/x-mif (mif))
    (application/x-ms-wmd (wmd))
    (application/x-ms-wmz (wmz))
    (application/x-msdos-program (com exe bat dll))
    (application/x-msi (msi))
    (application/x-netcdf (nc))
    (application/x-ns-proxy-autoconfig (pac dat))
    (application/x-nwc (nwc))
    (application/x-object (o))
    (application/x-oz-application (oza))
    (application/x-pkcs7-certreqresp (p7r))
    (application/x-pkcs7-crl (crl))
    (application/x-python-code (pyc pyo))
    (application/x-qgis (qgs shp shx))
    (application/x-quicktimeplayer (qtl))
    (application/x-redhat-package-manager (rpm))
    (application/x-ruby (rb))
    (application/x-sh (sh))
    (application/x-shar (shar))
    (application/x-shockwave-flash (swf swfl))
    (application/x-silverlight (scr))
    (application/x-stuffit (sit sitx))
    (application/x-sv4cpio (sv4cpio))
    (application/x-sv4crc (sv4crc))
    (application/x-tar (tar))
    (application/x-tcl (tcl))
    (application/x-tex-gf (gf))
    (application/x-tex-pk (pk))
    (application/x-texinfo (texinfo texi))
    (application/x-trash (~ % bak old sik))
    (application/x-troff (t tr roff))
    (application/x-troff-man (man))
    (application/x-troff-me (me))
    (application/x-troff-ms (ms))
    (application/x-ustar (ustar))
    (application/x-wais-source (src))
    (application/x-wingz (wz))
    (application/x-x509-ca-cert (crt))
    (application/x-xcf (xcf))
    (application/x-xfig (fig))
    (application/x-xpinstall (xpi))
    (audio/amr (amr))
    (audio/amr-wb (awb))
    (audio/amr (amr))
    (audio/amr-wb (awb))
    (audio/annodex (axa))
    (audio/basic (au snd))
    (audio/flac (flac))
    (audio/midi (mid midi kar))
    (audio/mpeg (mpga mpega mp2 mp3 m4a))
    (audio/mpegurl (m3u))
    (audio/ogg (oga ogg spx))
    (audio/prs.sid (sid))
    (audio/x-aiff (aif aiff aifc))
    (audio/x-gsm (gsm))
    (audio/x-mpegurl (m3u))
    (audio/x-ms-wma (wma))
    (audio/x-ms-wax (wax))
    (audio/x-pn-realaudio (ra rm ram))
    (audio/x-realaudio (ra))
    (audio/x-scpls (pls))
    (audio/x-sd2 (sd2))
    (audio/x-wav (wav))
    (chemical/x-alchemy (alc))
    (chemical/x-cache (cac cache))
    (chemical/x-cache-csf (csf))
    (chemical/x-cactvs-binary (cbin cascii ctab))
    (chemical/x-cdx (cdx))
    (chemical/x-cerius (cer))
    (chemical/x-chem3d (c3d))
    (chemical/x-chemdraw (chm))
    (chemical/x-cif (cif))
    (chemical/x-cmdf (cmdf))
    (chemical/x-cml (cml))
    (chemical/x-compass (cpa))
    (chemical/x-crossfire (bsd))
    (chemical/x-csml (csml csm))
    (chemical/x-ctx (ctx))
    (chemical/x-cxf (cxf cef))
    (chemical/x-embl-dl-nucleotide (emb embl))
    (chemical/x-galactic-spc (spc))
    (chemical/x-gamess-input (inp gam gamin))
    (chemical/x-gaussian-checkpoint (fch fchk))
    (chemical/x-gaussian-cube (cub))
    (chemical/x-gaussian-input (gau gjc gjf))
    (chemical/x-gaussian-log (gal))
    (chemical/x-gcg8-sequence (gcg))
    (chemical/x-genbank (gen))
    (chemical/x-hin (hin))
    (chemical/x-isostar (istr ist))
    (chemical/x-jcamp-dx (jdx dx))
    (chemical/x-kinemage (kin))
    (chemical/x-macmolecule (mcm))
    (chemical/x-macromodel-input (mmd mmod))
    (chemical/x-mdl-molfile (mol))
    (chemical/x-mdl-rdfile (rd))
    (chemical/x-mdl-rxnfile (rxn))
    (chemical/x-mdl-sdfile (sd sdf))
    (chemical/x-mdl-tgf (tgf))
    (chemical/x-mmcif (mcif))
    (chemical/x-mol2 (mol2))
    (chemical/x-molconn-Z (b))
    (chemical/x-mopac-graph (gpt))
    (chemical/x-mopac-input (mop mopcrt mpc zmt))
    (chemical/x-mopac-out (moo))
    (chemical/x-mopac-vib (mvb))
    (chemical/x-ncbi-asn1 (asn))
    (chemical/x-ncbi-asn1-ascii (prt ent))
    (chemical/x-ncbi-asn1-binary (val aso))
    (chemical/x-ncbi-asn1-spec (asn))
    (chemical/x-pdb (pdb ent))
    (chemical/x-rosdal (ros))
    (chemical/x-swissprot (sw))
    (chemical/x-vamas-iso14976 (vms))
    (chemical/x-vmd (vmd))
    (chemical/x-xtel (xtel))
    (chemical/x-xyz (xyz))
    (image/gif (gif))
    (image/ief (ief))
    (image/jpeg (jpeg jpg jpe))
    (image/pcx (pcx))
    (image/png (png))
    (image/svg+xml (svg svgz))
    (image/tiff (tiff tif))
    (image/vnd.djvu (djvu djv))
    (image/vnd.wap.wbmp (wbmp))
    (image/x-canon-cr2 (cr2))
    (image/x-canon-crw (crw))
    (image/x-cmu-raster (ras))
    (image/x-coreldraw (cdr))
    (image/x-coreldrawpattern (pat))
    (image/x-coreldrawtemplate (cdt))
    (image/x-corelphotopaint (cpt))
    (image/x-epson-erf (erf))
    (image/x-icon (ico))
    (image/x-jg (art))
    (image/x-jng (jng))
    (image/x-ms-bmp (bmp))
    (image/x-nikon-nef (nef))
    (image/x-olympus-orf (orf))
    (image/x-photoshop (psd))
    (image/x-portable-anymap (pnm))
    (image/x-portable-bitmap (pbm))
    (image/x-portable-graymap (pgm))
    (image/x-portable-pixmap (ppm))
    (image/x-rgb (rgb))
    (image/x-xbitmap (xbm))
    (image/x-xpixmap (xpm))
    (image/x-xwindowdump (xwd))
    (message/rfc822 (eml))
    (model/iges (igs iges))
    (model/mesh (msh mesh silo))
    (model/vrml (wrl vrml))
    (model/x3d+vrml (x3dv))
    (model/x3d+xml (x3d))
    (model/x3d+binary (x3db))
    (text/cache-manifest (manifest))
    (text/calendar (ics icz))
    (text/css (css))
    (text/csv (csv))
    (text/h323 (323))
    (text/html (html htm shtml))
    (text/iuls (uls))
    (text/mathml (mml))
    (text/plain (asc txt text pot brf))
    (text/richtext (rtx))
    (text/scriptlet (sct wsc))
    (text/texmacs (tm ts))
    (text/tab-separated-values (tsv))
    (text/vnd.sun.j2me.app-descriptor (jad))
    (text/vnd.wap.wml (wml))
    (text/vnd.wap.wmlscript (wmls))
    (text/x-bibtex (bib))
    (text/x-boo (boo))
    (text/x-c++hdr (h++ hpp hxx hh))
    (text/x-c++src (c++ cpp cxx cc))
    (text/x-chdr (h))
    (text/x-component (htc))
    (text/x-csh (csh))
    (text/x-csrc (c))
    (text/x-dsrc (d))
    (text/x-diff (diff patch))
    (text/x-haskell (hs))
    (text/x-java (java))
    (text/x-literate-haskell (lhs))
    (text/x-moc (moc))
    (text/x-pascal (p pas))
    (text/x-pcs-gcd (gcd))
    (text/x-perl (pl pm))
    (text/x-python (py))
    (text/x-scala (scala))
    (text/x-setext (etx))
    (text/x-sh (sh))
    (text/x-tcl (tcl tk))
    (text/x-tex (tex ltx sty cls))
    (text/x-vcalendar (vcs))
    (text/x-vcard (vcf))
    (text/javascript (json))
    (video/3gpp (3gp))
    (video/annodex (axv))
    (video/dl (dl))
    (video/dv (dif dv))
    (video/fli (fli))
    (video/gl (gl))
    (video/mpeg (mpeg mpg mpe))
    (video/mp4 (mp4))
    (video/quicktime (qt mov))
    (video/ogg (ogv))
    (video/vnd.mpegurl (mxu))
    (video/x-flv (flv))
    (video/x-la-asf (lsf lsx))
    (video/x-mng (mng))
    (video/x-ms-asf (asf asx))
    (video/x-ms-wm (wm))
    (video/x-ms-wmv (wmv))
    (video/x-ms-wmx (wmx))
    (video/x-ms-wvx (wvx))
    (video/x-msvideo (avi))
    (video/x-sgi-movie (movie))
    (video/x-matroska (mpv mkv))
    (x-conference/x-cooltalk (ice))
    (x-epoc/x-sisx-app (sisx))
    (x-world/x-vrml (vrm vrml wrl))

    ;; Scheme mime
    (text/scheme (sxml))
    (application/scheme (ss scm))))

;; NOTE: "application/octet-stream" should be the default if there's no further
;;       information to guess. Accroding to RFC1341:
;; http://www.w3.org/Protocols/rfc1341/4_Content-Type.html
;; "When a mail reader encounters mail with an unknown Content- type value, it
;; should generally treat it as equivalent to "application/octet-stream", as
;; described later in this document."
(define mime-guess
  (lambda (ext)
    (or (hash-ref *mime-types-table*
                  (cond
                   ((symbol? ext) ext)
                   ((string? ext) (string->symbol ext))
                   (else (throw 'artanis-err 500
                                "mime-guess: wrong ext type to guess mime!"))))
        'application/octet-stream)))

;; TODO: generate this table on the env init time, and save a copy in env.
(define *mime-types-table* (make-hash-table))

;; ENHANCEMENT: This search is inefficient since it's pure linked list, we may
;;              need faster data structure, although it's not necessary.
;; NOTE: mime-check is useful for checking if your program is wrong, so we
;;       throw error if it doesn't pass. It's recommended to use when debug
;;       mode is enabled.
(define (mime-check mime)
  (or
   (assq-ref
    *mime-types-table*
    (cond
     ((symbol? mime) mime)
    ((string? mime) (string->symbol mime))
    (else (throw 'artanis-err 500
                 "mime-check: Invalid MIME! Should be symbol or string" mime))))
   (throw 'artanis-err 500
          "mime-check: MIME check failed, maybe your program has bug?")))

;; init mime type table
(define (init-mime)
  (for-each
   (lambda (x)
     (let ((mtype (car x))
           (mimes (cadr x)))
       (for-each
        (lambda (m)
          (hash-set! *mime-types-table* m mtype))
        mimes)))
   mime-list))

(init-mime)
