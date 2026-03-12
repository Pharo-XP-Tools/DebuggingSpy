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

{ #category : 'examples' }
DSLoggingErrorRecord class >> example [
	"Returns an exemple of object for this class."

	^ self new
		  record: #ERROR;
		  windowId: MorphicNativeWindow basicNew hash;
		  yourself
]

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
