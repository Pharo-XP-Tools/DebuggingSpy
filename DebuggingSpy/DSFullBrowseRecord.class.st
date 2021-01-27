"
I record user browsing code action.
I store the browsed package, class, method and the window id in which it happened.
Elements are browsed in order `package>class>method`.
If one of them is nil, for instance, `package>class>nil`, it means that the user is browsing the class and possibly looking at its methods, or at the list of classes in the package, or at the packages list.
"
Class {
	#name : #DSFullBrowseRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'methodBrowsed',
		'windowId',
		'packageBrowsed',
		'classBrowsed'
	],
	#category : #'DebuggingSpy-Records'
}

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

{ #category : #'actions api' }
DSFullBrowseRecord >> record: aClyFullBrowser [

	packageBrowsed := aClyFullBrowser packageSelection isEmpty
		                  ifTrue: [ nil ]
		                  ifFalse: [ 
		                  aClyFullBrowser packageSelection lastSelectedItem
			                  actualObject ].
	classBrowsed := aClyFullBrowser classSelection isEmpty
		                ifTrue: [ nil ]
		                ifFalse: [ 
		                aClyFullBrowser classSelection lastSelectedItem
			                actualObject ].
	methodBrowsed := aClyFullBrowser methodSelection isEmpty
		                 ifTrue: [ nil ]
		                 ifFalse: [ 
		                 aClyFullBrowser methodSelection lastSelectedItem
			                 actualObject ].
	windowId := aClyFullBrowser window hash
]
