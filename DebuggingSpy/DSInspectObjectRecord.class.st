"
I record the opening of an inspector on an object
"
Class {
	#name : 'DSInspectObjectRecord',
	#superclass : 'DSInspectorRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSInspectObjectRecord >> eventName [
	^'Inspect object'
]

{ #category : 'accessing' }
DSInspectObjectRecord >> windowName [

	^ inspectedObject
]

{ #category : 'accessing' }
DSInspectObjectRecord >> windowType [
	^'Inspector'
]
