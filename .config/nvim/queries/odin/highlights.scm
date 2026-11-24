;; extends

(procedure_declaration
	(identifier) @function.definition
	(#set! priority 130))

(enum_declaration
	(identifier) @enum.definition
	(#set! priority 130))

(struct_declaration
	(identifier) @struct.definition
	(#set! priority 130))

(union_declaration
	(identifier) @union.definition
	(#set! priority 130))
