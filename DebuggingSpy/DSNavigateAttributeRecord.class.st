"
I record the inspection of an inspected object's attribute through selecting attributes in inspector tables
"
Class {
	#name : #DSNavigateAttributeRecord,
	#superclass : #DSInspectAttributeRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions api' }
DSNavigateAttributeRecord >> record: attributeWithModelAndWindow [

	super record: { 
			attributeWithModelAndWindow first first.
			attributeWithModelAndWindow first second.
			attributeWithModelAndWindow second }
]
