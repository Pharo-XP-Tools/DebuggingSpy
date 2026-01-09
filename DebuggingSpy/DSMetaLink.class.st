"
MetaLinks only used by Debugging Spy for instrumentation purpose.
"
Class {
	#name : 'DSMetaLink',
	#superclass : 'MetaLink',
	#category : 'DebuggingSpy-Instrumentation',
	#package : 'DebuggingSpy',
	#tag : 'Instrumentation'
}

{ #category : 'accessing' }
DSMetaLink class >> linkInstaller [ 
	^linkInstaller
		ifNil: [ linkInstaller := DSMetaLinkInstaller new ]
	
]
