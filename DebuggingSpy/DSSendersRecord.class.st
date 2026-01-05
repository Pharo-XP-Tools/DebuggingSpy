"
Record when user is searching for senders of a class, method, ...
"
Class {
	#name : 'DSSendersRecord',
	#superclass : 'DSAbstractBrowserRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSSendersRecord >> eventName [
	^ 'Senders'
]
