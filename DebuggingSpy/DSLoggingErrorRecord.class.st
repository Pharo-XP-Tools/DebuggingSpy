"
I am generated when an event provokes an error while instantiating a Debugging Spy record.
"
Class {
	#name : 'DSLoggingErrorRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'event'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSLoggingErrorRecord >> event [

	^ event
]

{ #category : 'accessing' }
DSLoggingErrorRecord >> eventName [
	^'Error'
]

{ #category : 'actions api' }
DSLoggingErrorRecord >> record: anEventError [
	event := anEventError 
]
