"
I record user browsing queries results (implementors, selectors...).
I store the name of the query and the id of the window
"
Class {
	#name : #DSQueryBrowseRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'queryName',
		'windowId'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSQueryBrowseRecord >> eventName [
	^'Query'
]

{ #category : #accessing }
DSQueryBrowseRecord >> queryName [

	^ queryName
]

{ #category : #accessing }
DSQueryBrowseRecord >> queryName: anObject [

	queryName := anObject
]

{ #category : #'actions api' }
DSQueryBrowseRecord >> record: aClyQueryBrowser [

	queryName := aClyQueryBrowser systemQuery description.
	windowId := aClyQueryBrowser window hash
]

{ #category : #accessing }
DSQueryBrowseRecord >> windowId [

	^ windowId
]

{ #category : #accessing }
DSQueryBrowseRecord >> windowId: anObject [

	windowId := anObject
]
