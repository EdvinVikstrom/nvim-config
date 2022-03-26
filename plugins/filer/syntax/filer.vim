if exists('b:current_syntax')
  finish
endif

syntax match filerIndicator '^\s*..'
syntax match filerDir '.*/$' contains=filerIndicator
syntax match filerLink '^.*@$'
syntax match filerBlock '^.*#$'
syntax match filerChar '^.*%$'
syntax match filerSocket '^.*=$'
syntax match filerFIFO '^.*|$'
syntax match filerPriv '^.*\~$'

hi def link filerIndicator Operator
hi def link filerDir Identifier
hi def link filerLink Question
hi def link filerBlock StorageClass
hi def link filerChar Constant
hi def link filerSocket Structure
hi def link filerFIFO Label
hi def link filerPriv Comment

let b:current_syntax = 'filer'
