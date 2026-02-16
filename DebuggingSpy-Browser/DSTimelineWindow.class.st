"
I am a class representing a plot for the DSSpy visualizer timeline.
"
Class {
	#name : 'DSTimelineWindow',
	#superclass : 'Object',
	#instVars : [
		'color',
		'points'
	],
	#category : 'DebuggingSpy-Browser',
	#package : 'DebuggingSpy-Browser'
}

{ #category : 'instance creation' }
DSTimelineWindow class >> for: aWindow [

	^ self new processWindow: aWindow
]

{ #category : 'accessing' }
DSTimelineWindow >> color [

	^ color
]

{ #category : 'accessing' }
DSTimelineWindow >> color: newColor [

	color := newColor
]

{ #category : 'accessing' }
DSTimelineWindow >> points [

	^ points
]

{ #category : 'accessing' }
DSTimelineWindow >> points: newPoints [

	points := newPoints
]

{ #category : 'processing' }
DSTimelineWindow >> processWindow: aWindow [

	points := {
		          aWindow events first dateTime asSeconds.
		          aWindow events last dateTime asSeconds }.
	color := DSRecordBrowserPresenter getWindowColorFor: aWindow
]
