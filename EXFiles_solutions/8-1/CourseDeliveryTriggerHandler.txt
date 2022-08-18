public class CourseDeliveryTriggerHandler {

    //TODO #1: Review the following static initialization block.
    //         It encapsulates some of the logic that was formerly found in the trigger.
    //         We moved the declaration and query of the set of holiday dates
    //         to a static initialization block because the data is likely not
    //         to change within the apex transaction context and this ensures
    //         the query is executed exactly once regardless how many times the
    //         preventInvalidCourseDeliveries method is called in a given transaction.
    //         This kind of caching helps to stay within SOQL query limits.
    public static Set<Date> allHolidays = new Set<Date>();

    static {
        //Fetch the current holidays.
        //For simplicity's sake, we've assumed no recurring holidays
        for (List<Holiday> holidays : [SELECT ActivityDate FROM Holiday]) {
            for (Holiday h : holidays) {
                allHolidays.add(h.ActivityDate);
            }
        }
    }

    //TODO #2: Review the following static method.
    //         It encapsulates the logic that was formerly found in the trigger.
    //         It is static, so it can be invoked without instantiating the class.
    public static void preventInvalidCourseDeliveries(List<Course_Delivery__c> newCourseDeliveryList,
                                                      Map<ID, Course_Delivery__c> oldCourseDeliveryMap) {
        //TODO #3: Review the following for-loop.
        //         Notice that instead of referencing Trigger.new directly
        //         in the helper class as was done in the trigger, we now
        //         reference a list variable passed to the method. Trigger.oldMap
        //         is passed in so that the Start_Date__c can be compared on Update.
        //         This improves testability and code reuse.
        for (Course_Delivery__c courseDelivery : newCourseDeliveryList) {
			Boolean checkDate = (trigger.isInsert || 
				oldCourseDeliveryMap.get(courseDelivery.Id).Start_Date__c != courseDelivery.Start_Date__c);
			if (checkDate && courseDelivery.Start_Date__c != NULL) {
                //Prevent the invoking DML action if the Start Date is in the allHolidays set.
                if ( allHolidays.contains(courseDelivery.Start_Date__c) ) {
                    courseDelivery.Start_Date__c.addError('Course Delivery cannot be scheduled because it starts on a holiday.');
                }
            }
        }
    }
}