"
I am an abstract class for records linked to the Sindarin debugger.
"
Class {
	#name : 'DSAbstractSindarinActionRecord',
	#superclass : 'DSAbstractEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'testing' }
DSAbstractSindarinActionRecord class >> isAbstract [

	^ self == DSAbstractSindarinActionRecord
]
