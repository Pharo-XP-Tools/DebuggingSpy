Class {
	#name : 'DSWindowElementAnnotationPresenter',
	#superclass : 'StInspection',
	#instVars : [
		'windowElement',
		'indexField',
		'annotationText'
	],
	#category : 'DebuggingSpy-Presenters',
	#package : 'DebuggingSpy',
	#tag : 'Presenters'
}

{ #category : 'layout' }
DSWindowElementAnnotationPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 35 percent;
				   add: (self newLabel label: 'Index'; yourself);
				   add: indexField;
				   yourself)  expand: false  fill: false  padding: 0;
		  add: (self newLabel label:'Annotation'; yourself)  expand: false  fill: false  padding: 0;
		  add: annotationText;
		  yourself
]

{ #category : 'initialization' }
DSWindowElementAnnotationPresenter >> initializePresenters [ 
	super initializePresenters.
	
	indexField := self newNumberInput.
	indexField number: windowElement annotation index.
	
	annotationText := self newText.
	annotationText text: windowElement annotation annotation.
		
	indexField whenTextChangedDo: [ windowElement annotation index: indexField number  ].		
	annotationText whenTextChangedDo: [ windowElement annotation annotation: annotationText text  ]
	

]

{ #category : 'accessing - model' }
DSWindowElementAnnotationPresenter >> setModelBeforeInitialization: aDSWindowOrWindowActivity [

	windowElement := aDSWindowOrWindowActivity
]
