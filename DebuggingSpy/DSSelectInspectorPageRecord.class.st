"
I record the selection of an inspector page when inspecting an object
"
Class {
	#name : #DSSelectInspectorPageRecord,
	#superclass : #DSInspectorRecord,
	#instVars : [
		'pageName'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSSelectInspectorPageRecord >> eventName [
	^'Selecting inspector page'
]
