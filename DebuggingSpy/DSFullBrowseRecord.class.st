"
I record user browsing code action.
I store the browsed package, class and method names, and the window id in which it happened.
Elements are browsed in order `package>class>method`.
If one of them is nil, for instance, `package>class>nil`, it means that the user is browsing the class and possibly looking at its methods, or at the list of classes in the package, or at the packages list.

I have to register names instead of objects, as there are no guarantees that the image that analyzes the record has these package/class/method.
"
Class {
	#name : #DSFullBrowseRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'methodBrowsed',
		'packageBrowsed',
		'classBrowsed'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSFullBrowseRecord >> classBrowsed [

	^ classBrowsed
]

{ #category : #accessing }
DSFullBrowseRecord >> classBrowsed: anObject [

	classBrowsed := anObject
]

{ #category : #accessing }
DSFullBrowseRecord >> eventName [
	^'Browse'
]

{ #category : #accessing }
DSFullBrowseRecord >> methodBrowsed [

	^ methodBrowsed
]

{ #category : #accessing }
DSFullBrowseRecord >> methodBrowsed: anObject [

	methodBrowsed := anObject
]

{ #category : #accessing }
DSFullBrowseRecord >> packageBrowsed [

	^ packageBrowsed
]

{ #category : #accessing }
DSFullBrowseRecord >> packageBrowsed: anObject [

	packageBrowsed := anObject
]

{ #category : #'actions api' }
DSFullBrowseRecord >> record: aClyFullBrowser [

	packageBrowsed := aClyFullBrowser packageSelection isEmpty
		                  ifTrue: [ '' ]
		                  ifFalse: [ 
		                  aClyFullBrowser packageSelection lastSelectedItem
			                  actualObject name ].
	classBrowsed := aClyFullBrowser classSelection isEmpty
		                ifTrue: [ '' ]
		                ifFalse: [ 
		                aClyFullBrowser classSelection lastSelectedItem
			                actualObject name ].
	methodBrowsed := aClyFullBrowser methodSelection isEmpty
		                 ifTrue: [ '' ]
		                 ifFalse: [ 
		                 aClyFullBrowser methodSelection lastSelectedItem
			                 actualObject name ].
	windowId := aClyFullBrowser window hash
]
