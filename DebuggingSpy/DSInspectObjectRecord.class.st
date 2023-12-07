"
I record the opening of an inspector on an object
"
Class {
	#name : #DSInspectObjectRecord,
	#superclass : #DSInspectorRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSInspectObjectRecord >> eventName [
	^'Inspect object'
]

{ #category : #accessing }
DSInspectObjectRecord >> windowName [

	^ inspectedObject
]

{ #category : #'as yet unclassified' }
DSInspectObjectRecord >> windowType [
	^'Inspector'
]
