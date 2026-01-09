"
Installer for DSMetaLinks, it allows to uninstall all DSMetaLinks easily
"
Class {
	#name : 'DSMetaLinkInstaller',
	#superclass : 'MetaLinkInstaller',
	#category : 'DebuggingSpy-Instrumentation',
	#package : 'DebuggingSpy',
	#tag : 'Instrumentation'
}

{ #category : 'updating' }
DSMetaLinkInstaller >> methodChanged: aMethodChanged [

	| links dsLink newMethod |
	super methodChanged: aMethodChanged.

	links := aMethodChanged oldMethod compiledMethod ast links.

	links ifEmpty: [ ^ self ].

	dsLink := links detect: [ :link | link class = DSMetaLink ] ifNone: [ ^ self ].

	newMethod := aMethodChanged newMethod.

	newMethod methodClass link: dsLink toAST: newMethod ast
]
