"
I record variable breakpoint events information.
"
Class {
	#name : #DSVariableBreakpointEventRecord,
	#superclass : #DSAbstractBreakpointEventRecord,
	#instVars : [
		'targetClassOrMethod',
		'targetVariables'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions api' }
DSVariableBreakpointEventRecord >> record: aBreakpointEvent [
	super record: aBreakpointEvent.
	targetClassOrMethod := aBreakpointEvent breakpoint targetClassOrMethod name.
	targetVariables := aBreakpointEvent breakpoint targetVariableNames 
]

{ #category : #accessing }
DSVariableBreakpointEventRecord >> targetClassOrMethod [

	^ targetClassOrMethod
]

{ #category : #accessing }
DSVariableBreakpointEventRecord >> targetVariables [

	^ targetVariables
]
