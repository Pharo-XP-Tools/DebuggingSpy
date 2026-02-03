"
I am a class that reprensent object target record for debugPoint.
"
Class {
	#name : 'DSDebugPointObjectTargetRecord',
	#superclass : 'DSAbstractDebugPointTargetRecord',
	#instVars : [
		'subTarget'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'actions api' }
DSDebugPointObjectTargetRecord >> record: aDebugPointTarget [

	super record: aDebugPointTarget.
	subTarget := aDebugPointTarget subTarget 
]

{ #category : 'accessing' }
DSDebugPointObjectTargetRecord >> subTarget [ 

	^ subTarget 
]
