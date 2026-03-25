"
I record breakpoint events information.
"
Class {
	#name : 'DSBreakDebugPointEventRecord',
	#superclass : 'DSAbstractDebugPointEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'converting' }
DSBreakDebugPointEventRecord >> modelClass [

	^ DSMethodDebugPointRecord
]
