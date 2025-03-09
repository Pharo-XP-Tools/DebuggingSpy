"
I record the selection of an inspector page when inspecting an object
"
Class {
	#name : 'DSSelectInspectorPageRecord',
	#superclass : 'DSInspectorRecord',
	#instVars : [
		'pageTitle'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSSelectInspectorPageRecord >> eventName [
	^'Selecting inspector tab'
]

{ #category : 'accessing' }
DSSelectInspectorPageRecord >> pageTitle [

	^ pageTitle
]

{ #category : 'accessing' }
DSSelectInspectorPageRecord >> pageTitle: anObject [

	pageTitle := anObject
]

{ #category : 'actions api' }
DSSelectInspectorPageRecord >> record: pageTitleWithInspectedObjectWithWindow [

	super record: { 
			pageTitleWithInspectedObjectWithWindow second.
			pageTitleWithInspectedObjectWithWindow last }.
	pageTitle := pageTitleWithInspectedObjectWithWindow first
]
