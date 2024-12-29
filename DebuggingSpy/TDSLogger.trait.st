"
Common API for DSSpy surveys
"
Trait {
	#name : #TDSLogger,
	#category : #'DebuggingSpy-Loggers'
}

{ #category : #logging }
TDSLogger >> log: aDSEventRecord [
	self explicitRequirement
]

{ #category : #initialization }
TDSLogger >> reset [
	self explicitRequirement 
]

{ #category : #setup }
TDSLogger >> setupLoggerAfterSurvey: aSurvey [
	self explicitRequirement
]

{ #category : #setup }
TDSLogger >> setupLoggerBeforeSurvey: aSurvey [
	self explicitRequirement "self forceLoggingFileNameFor: aTask."
]

{ #category : #setup }
TDSLogger >> setupLoggerForTask: aTask [
	self explicitRequirement
]
