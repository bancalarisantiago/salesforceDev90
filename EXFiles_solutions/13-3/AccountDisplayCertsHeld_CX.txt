public with sharing class AccountDisplayCertsHeld_CX {
    /**
     *  This Extension Controller is used to populate
     *  a table of Certifications Held that are
     *  related to a specific Account and displayed
     *  in-line on the detail page for that Account
     */

    private final Account acct;

    /** TODO #1: Declare a public Constructor named AccountDisplayCertsHeld_CX
     *           that includes an input parameter whose type is ApexPages.StandardController
     *           named stdController. Within the constructor assign the controller's
     *           instance acct variable the result of calling the
     *           getRecord method of the stdController and casting it to the Account type.
     */
    public AccountDisplayCertsHeld_CX(ApexPages.StandardController stdController) {
        this.acct = (Account) stdController.getRecord();
    }
	
    /** TODO #2: Declare a read-only property whose type is a List of Certification_Held__c
     *           sObjects, named results and have it include:
     *             -- an if statement that, if the results property is null
     *                -- Assign the results property to a new instance of a list of Certification_Held__c
     *                   sObjects that will accept as a parameter a SOQL query that:
     *                   -- Selects the Id, Name, Date_Achieved__c, and Certified_Professional__r.Name fields
     *                   -- From the Certification_Held__c sObject
     *                   -- Where the value of the AccountId field of the Certified_Professional__r sObject
     *                      equals the Id of the acct variable
     *                -- Return the results property
     *             Be sure to include the private set property;
     */
    public List<Certification_Held__c> results {
        get {
            if (results == null) {
                results = new List<Certification_Held__c> ([SELECT Id, Name, Date_Achieved__c, Certified_Professional__r.Name
                                                            FROM Certification_Held__c
                                                            WHERE Certified_Professional__r.AccountId = :acct.Id]);
            }
            return results;
        }
        private set;
    }
}
