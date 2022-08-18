@isTest
private class CourseManager_Test {

    private static List<Course__c> createTestDataCourses(Integer startValue, 
														 Integer endValue) {
        List<Course__c> coursesToAdd = new List<Course__c>();
        for (Integer i = startValue; i <= endValue; i++) {
            Course__c course = new Course__c(name = 'Course ' + i);
            coursesToAdd.add(course);
        }
        return coursesToAdd;
    }

    @isTest
    private static void testFindDuplicates () {
        List<Course__c> oldCourses = createTestDataCourses(0, 5);
        List<Course__c> newCourses = createTestDataCourses(3, 6);
        Test.startTest();
        Set<Course__c> duplicateCourses = CourseManager.findDuplicates(oldCourses, 
																	   newCourses);
        Test.stopTest();
        System.assert(duplicateCourses.size()==3);
    }
}
