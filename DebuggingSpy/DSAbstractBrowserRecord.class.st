"
Abstract record for events linked to the browser : browse, senders, implementors, ...
"
Class {
	#name : 'DSAbstractBrowserRecord',
	#superclass : 'DSAbstractEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions api' }
DSAbstractBrowserRecord >> record: aCommandObject [

	self windowId: aCommandObject recordWindow identityHash 
]
