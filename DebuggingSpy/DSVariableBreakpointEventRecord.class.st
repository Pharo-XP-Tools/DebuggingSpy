"
I record variable breakpoint events information.
"
Class {
	#name : 'DSVariableBreakpointEventRecord',
	#superclass : 'DSAbstractBreakpointEventRecord',
	#instVars : [
		'targetClassOrMethod',
		'targetVariables',
		'accessStrategy'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSVariableBreakpointEventRecord >> accessStrategy [

	^ accessStrategy
]

{ #category : 'converting' }
DSVariableBreakpointEventRecord >> modelClass [

	^ DSVariableBreakpointRecord
]

{ #category : 'actions api' }
DSVariableBreakpointEventRecord >> record: aBreakpointEvent [
	super record: aBreakpointEvent.
	targetClassOrMethod := aBreakpointEvent breakpoint targetClassOrMethod name.
	targetVariables := aBreakpointEvent breakpoint targetVariableNames .
	accessStrategy := aBreakpointEvent breakpoint accessStrategy
]

{ #category : 'accessing' }
DSVariableBreakpointEventRecord >> targetClassOrMethod [

	^ targetClassOrMethod
]

{ #category : 'accessing' }
DSVariableBreakpointEventRecord >> targetVariables [

	^ targetVariables
]
