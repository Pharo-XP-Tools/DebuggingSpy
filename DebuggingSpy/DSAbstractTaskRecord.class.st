"
I am an optional record to manage tasks starting and ending in empirical experiments.
My subclasses specialize me to provide specific task management.

Tasks should be objects answering `#name` and `#description`, both returning a string.
"
Class {
	#name : #DSAbstractTaskRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'taskName',
		'description'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSAbstractTaskRecord >> description [

	^ description
]

{ #category : #'actions api' }
DSAbstractTaskRecord >> record: aTask [
	taskName := aTask name.
	description := aTask description.
]

{ #category : #accessing }
DSAbstractTaskRecord >> taskName [

	^ taskName
]
