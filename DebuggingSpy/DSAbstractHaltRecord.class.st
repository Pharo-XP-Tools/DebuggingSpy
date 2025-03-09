"
My subclasses record particular halts events such as: installing a halt, or hitting a halt at run time.
"
Class {
	#name : 'DSAbstractHaltRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'method',
		'sourceCodeInterval'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSAbstractHaltRecord >> method [

	^ method
]

{ #category : 'actions api' }
DSAbstractHaltRecord >> record: anRBProgramNode [

	method := anRBProgramNode methodNode compiledMethod name.
	sourceCodeInterval := anRBProgramNode start to: anRBProgramNode stop
]

{ #category : 'accessing' }
DSAbstractHaltRecord >> sourceCodeInterval [

	^ sourceCodeInterval
]
