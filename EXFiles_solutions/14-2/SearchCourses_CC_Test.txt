@isTest
private class SearchCourses_CC_Test {
    
    @testSetup
    private static void loadTestData() {
        
        // TODO #1:
        // Load the test data. Use the LoadDataTestFactory class to load User, Certification and Course records (in that order)
        List<User> users = LoadDataTestFactory.createUsers();
        List<Certification__c> certs = LoadDataTestFactory.loadCertifications();
        List<Course__c> courses = LoadDataTestFactory.loadCourses();        
    }
    
    @isTest
    private static void testSearchCoursesNavigation() {
              
	// TODO #2: Set the current page
        PageReference searchCoursesPage = Page.SearchCoursesPage;
        Test.setCurrentPage(searchCoursesPage);
        
        // Do the test
        Test.startTest();
        
        // TODO #3: Instantiate the controller
        SearchCourses_CC sc = new SearchCourses_CC();
        
        // TODO #4: Get the list of CourseWrapper elements
        List<SearchCourses_CC.CourseWrapper> courseWrappers = sc.courseList;
        
        // TODO #5: Modify the list by checking all the elements
        for (SearchCourses_CC.CourseWrapper wrapper : courseWrappers) {
            wrapper.checked = true;
        }
        
        // TODO #6: Set modified list back to controller
        sc.courseList = courseWrappers;
        
        // TODO #7: Navigate to ListResultsPage by callng the listDeliveries method - capture the resulting url
        String url = sc.listDeliveries().getURL();
        
        Test.stopTest();
        
        // Verify the results
        
        // TODO #8: Check that all the elements have the boolean "checked" set to true
        List<SearchCourses_CC.CourseWrapper> courseWrappersModified = sc.courseList;
        Integer count = 0;
        for (SearchCourses_CC.CourseWrapper wrapper : courseWrappersModified) {
            if ( !wrapper.checked) count++;
        }
		System.assertEquals(0, count, 'ERROR: Found at least one CourseWrapper element not checked');
        
        // TODO #9: Check the correct navigation to ListCourseDeliveriesPage
        System.assertEquals(Page.ListCourseDeliveriesPage.getURL(), url, 'ERROR: Expected to navigate to /apex/listcoursedeliveriespage');
    }
}