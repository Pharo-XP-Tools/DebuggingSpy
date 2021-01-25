"
I represent an abstract window event record, typically an opening, closing, resizing, or activation of a window.
I hold a unique window ID that corresponds to the original window object's identity hash. This ID should be used to group together all events related to that particular window.

I should be used from my class-side interface, called on my subclasses to match particular window events.
"
Class {
	#name : #DSWindowEventRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'windowName',
		'windowId'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions api' }
DSWindowEventRecord >> record: aWindowEvent [
	self recordWindowIdFromEvent: aWindowEvent.
	self recordWindowNameFromEvent: aWindowEvent
]

{ #category : #recording }
DSWindowEventRecord >> recordWindowIdFromEvent: anEvent [
	|win|
	win := anEvent window.
	windowId := win hash
]

{ #category : #recording }
DSWindowEventRecord >> recordWindowNameFromEvent: anEvent [
	|win label|
	win := anEvent window.
	label := [win labelString ] on: Error do:['Unknown window'].
	windowName := label, ' (', win hash printString, ')'
]

{ #category : #comparing }
DSWindowEventRecord >> sameWindowAsIn: aDSWindowEventRecord [
	^self windowId = aDSWindowEventRecord windowId
]

{ #category : #accessing }
DSWindowEventRecord >> windowId [

	^ windowId
]

{ #category : #accessing }
DSWindowEventRecord >> windowId: anObject [

	windowId := anObject
]

{ #category : #accessing }
DSWindowEventRecord >> windowName [

	^ windowName
]

{ #category : #accessing }
DSWindowEventRecord >> windowName: anObject [

	windowName := anObject
]
