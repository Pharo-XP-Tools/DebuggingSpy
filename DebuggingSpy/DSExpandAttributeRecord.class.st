"
I record the inspection of an inspected object's attribute through expanding inspector trees
"
Class {
	#name : #DSExpandAttributeRecord,
	#superclass : #DSInspectAttributeRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions - api' }
DSExpandAttributeRecord >> record: aFTTableItem [

	super record: { 
			aFTTableItem data.
			aFTTableItem data hostObject.
			aFTTableItem dataSource model window }
]
