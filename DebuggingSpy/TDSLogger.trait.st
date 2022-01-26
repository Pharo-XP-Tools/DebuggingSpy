"
Common API for DSSpy surveys
"
Trait {
	#name : #TDSLogger,
	#category : #'DebuggingSpy-Loggers'
}

{ #category : #initialization }
TDSLogger >> reset [
	self explicitRequirement 
]

{ #category : #setup }
TDSLogger >> setupLoggerForSurvey: aSurvey [
	self explicitRequirement "self forceLoggingFileNameFor: aTask."
]

{ #category : #setup }
TDSLogger >> setupLoggerForTask: aTask [
	self explicitRequirement
]
