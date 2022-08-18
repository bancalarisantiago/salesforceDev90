trigger CourseDeliveryTrigger on Course_Delivery__c (before insert, before update) {
    
    //TODO #1: Review the for loop to see how we are populating allHolidays
    //  We have assumed that there are no recurring Holidays, for simplicity's sake.
    Set<Date> allHolidays = new Set<Date>();
    for (List<Holiday> holidays : [SELECT ActivityDate FROM Holiday]) {
        for (Holiday h : holidays) {
            allHolidays.add(h.ActivityDate);
        }
    }
    
    for (Course_Delivery__c courseDelivery : Trigger.new) {
		// Always check Inserts, but only check Updates when the Delivery
        //   Date just changed:
        Boolean checkDate = (trigger.isInsert || 
            trigger.oldMap.get(courseDelivery.Id).Start_Date__c != 
                                            courseDelivery.Start_Date__c);
        if (checkDate && courseDelivery.Start_Date__c != NULL) {
            //TODO #2: Prevent the invoking DML action if the Start Date is 
            //  in the allHolidays set.  Create an If statement that 
            //  determines if the Set allHolidays contains the courseDelivery 
            //  Start Date. Use the addError method of the sObject class to
            //  add the following error to the courseDelivery sObject:
            //  Course Delivery cannot be scheduled because it starts on a holiday.
            IF (allHolidays.contains(courseDelivery.Start_Date__c)) {
                courseDelivery.Start_Date__c.addError(
                    'Course Delivery cannot be scheduled because it starts on a holiday.');
            }
        }
    }
}