[![License GPL 3][badge-license]](http://www.gnu.org/licenses/gpl-3.0.txt)
[![MELPA][melpa-badge]][melpa-package]
[![MELPA Stable][melpa-stable-badge]][melpa-stable-package]

autodisass-java-bytecode
========================

This package enables the automatic disassembly of Java bytecode inside
Emacs buffers. It was inspired by a
[blog post](http://nullprogram.com/blog/2012/08/01/) of
[Christopher Wellons](https://github.com/skeeto).

Disassembly can happen in two cases:

1. when opening a Java .class file
2. when extracting a .class file inside a jar

In any case, `javap` must be installed in the system for this
extension to have any effect, since that is the tool that actually
performs the disassembly.


## Installation

You can install this package using the `package.el` built-in package
manager in Emacs. It is available on [MELPA](http://melpa.org/#/) and
[MELPA Stable](http://stable.melpa.org/#/) repos.

If you have these enabled, simply run:

    M-x package-install [RET] autodisass-java-bytecode [RET]


Alternatively, you can save
[this .el file](autodisass-java-bytecode.el) to a directory in your
*load-path*, and add the following to your `.emacs`:

    (require 'autodisass-java-bytecode)
    
## Disassembler settings

By default this mode uses `javap` do disassemble byte-code and
built-in `ad-javap-mode` to view disassebmled output.

Hovewer, it can be configured to use modern decompilers such as
[CFR](https://github.com/leibnitz27/cfr) or
[Fernflower](https://github.com/JetBrains/intellij-community/tree/master/plugins/java-decompiler/engine)

To do this, you need to configure following customization options:
- `ad-java-bytecode-arg-formatter` - Function to assemble list of arguments for disassembler invocation.
- `ad-java-disassembler-mode` - Function to run after disassembly was done, ususally mode-setting 

Currently provided convinience functions
`ad-java-disassembler-setup-cfr` and
`ad-java-disassembler-setup-javap` 
to quickly switch between CFR and javap.

[badge-license]: https://img.shields.io/badge/license-GPL_3-green.svg
[melpa-badge]: http://melpa.org/packages/autodisass-java-bytecode-badge.svg
[melpa-stable-badge]: http://stable.melpa.org/packages/autodisass-java-bytecode-badge.svg
[melpa-package]: http://melpa.org/#/autodisass-java-bytecode
[melpa-stable-package]: http://stable.melpa.org/#/autodisass-java-bytecode
