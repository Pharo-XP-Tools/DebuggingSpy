"
Record when a user is searching for implementors of a class, method, ...
"
Class {
	#name : 'DSImplementorsRecord',
	#superclass : 'DSAbstractBrowserRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSImplementorsRecord >> eventName [
	^ 'Implementors'
]
