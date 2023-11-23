"
I represent recorded events from an open inspector (standalone or embedded in another presenter).
"
Class {
	#name : 'DSInspectorRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'inspectedObject',
		'inspectedObjectHash'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSInspectorRecord >> inspectedObject [

	^ inspectedObject
]

{ #category : 'accessing' }
DSInspectorRecord >> inspectedObject: anObject [

	inspectedObject := anObject
]

{ #category : 'accessing' }
DSInspectorRecord >> inspectedObjectHash [

	^ inspectedObjectHash
]

{ #category : 'accessing' }
DSInspectorRecord >> inspectedObjectHash: anObject [

	inspectedObjectHash := anObject
]

{ #category : 'actions api' }
DSInspectorRecord >> record: inspectedObjectAndWindow [

	super record: inspectedObjectAndWindow second.
	inspectedObject := inspectedObjectAndWindow first printString.
	inspectedObjectHash := inspectedObjectAndWindow first identityHash 
]
