"
I record variable breakpoint events information.
"
Class {
	#name : 'DSWatchDebugPointEventRecord',
	#superclass : 'DSAbstractDebugPointEventRecord',
	#instVars : [
		'history',
		'limit'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSWatchDebugPointEventRecord >> history [

	^ history
]

{ #category : 'accessing' }
DSWatchDebugPointEventRecord >> limit [

	^ limit
]

{ #category : 'converting' }
DSWatchDebugPointEventRecord >> modelClass [

	^ DSMethodDebugPointRecord 
]

{ #category : 'actions api' }
DSWatchDebugPointEventRecord >> record: aDebugPointEvent [
	super record: aDebugPointEvent.
	limit := aDebugPointEvent debugPoint limit.
	history := aDebugPointEvent debugPoint history.
]
