"
I am an optional record to manage tasks starting and ending in empirical experiments.
My subclasses specialize me to provide specific task management.

Tasks should be objects answering `#name` and `#description`, both returning a string.
"
Class {
	#name : #DSAbstractTaskRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'task'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSAbstractTaskRecord >> description [

	^ task description
]

{ #category : #'actions api' }
DSAbstractTaskRecord >> record: aTask [
	task := aTask
]

{ #category : #accessing }
DSAbstractTaskRecord >> taskName [

	^ task name
]
