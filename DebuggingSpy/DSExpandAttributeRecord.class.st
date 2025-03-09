"
I record the inspection of an inspected object's attribute through expanding inspector trees
"
Class {
	#name : 'DSExpandAttributeRecord',
	#superclass : 'DSInspectAttributeRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions - api' }
DSExpandAttributeRecord >> record: aFTTableItem [
	|window|
	window := aFTTableItem dataSource model window.
	(window isKindOf: SpWindowPresenter) ifTrue:[window := window window].
	super record: { 
			aFTTableItem data.
			aFTTableItem data hostObject.
			window}
]
