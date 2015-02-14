((el-get status "installed" recipe
         (:name el-get :website "https://github.com/dimitri/el-get#readme" :description "Manage the external elisp bits and pieces you depend upon." :type github :branch "master" :pkgname "dimitri/el-get" :info "." :compile
                ("el-get.*\\.el$" "methods/")
                :load "el-get.el"))
 (nxhtml status "installed" recipe
         (:name nxhtml :type emacsmirror :description "An addon for Emacs mainly for web development." :build
                `((,el-get-emacs "-batch" "-q" "-no-site-file" "-L" "." "-l" "nxhtmlmaint.el" "-f" "nxhtmlmaint-start-byte-compilation"))
                :load "autostart.el"))
 (php-mode-improved status "installed" recipe
                    (:name php-mode-improved :description "Major mode for editing PHP code. This is a version of the php-mode from http://php-mode.sourceforge.net that fixes a few bugs which make using php-mode much more palatable" :type emacswiki :load
                           ("php-mode-improved.el")
                           :features php-mode)))
