trigger CertificationAttemptTrigger on Certification_Attempt__c (before insert, after insert, after update) 
{
    SWITCH ON Trigger.OperationType {
	
		WHEN BEFORE_INSERT {
			CertificationAttemptTriggerHandler.validateCertificationAttempt(Trigger.new);
		}
		WHEN AFTER_UPDATE {
			CertificationAttemptTriggerHandler.grantInstructorSharingAccess(Trigger.new,
									Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
			CertificationAttemptTriggerHandler.createCertificationHeld(Trigger.new, Trigger.oldMap);
		}
		WHEN AFTER_INSERT {
			CertificationAttemptTriggerHandler.grantInstructorSharingAccess(Trigger.new,
									Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
			CertificationAttemptTriggerHandler.createCertificationHeld(Trigger.new, Trigger.oldMap);
		}
	}
}