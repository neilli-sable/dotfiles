(setq debug-on-error t)
(eval-when-compile (require 'cl))
(delete-other-windows)
(eval-after-load 'nxhtml '(setq nxhtml-skip-welcome t))
(setq nxhtmltest-default-fontification-method 'fontify-as-ps-print)
(pushnew "c:/emacs/emacs-24.0.92/lisp/progmodes/" load-path)
