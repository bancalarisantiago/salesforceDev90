//(OPTIONAL) TASK 3: Find records created using a particular record type.
//--------------------------------------------------------------------------------------------

//WHERE CLAUSE SPECIFICATION: 
//      The WHERE clause you are constructing should determine if the RecordTypeId
//      field of the Case sObject (which is in the FROM clause) is
//      equal to the id value stored in the productSupportId variable.
//      To do this, assign the whereClause variable a value composed of
//      3 parts concatenated together:
//      - A string literal that provides everything that should comprise the WHERE clause
//        up to and including single quotation mark that should surround the id value
//        being provided by the productSupportId variable. (To include a single quotation
//        mark as part of the string, you will need to escape it with the \ character.)
//      - the variable productSupportId
//      - a string literal containing the closing single quotation mark.

//TODO: Review the following code that returns the Id of a Record Type. No changes necessary.
Id productSupportId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_Support').getRecordTypeId();

String selectClause = 'SELECT Id, Status, Subject ';
String fromClause = 'FROM Case ';
//TODO: fill in the whereClause variable according to the spec
String whereClause =  'WHERE RecordTypeId = :productSupportId'; 

String fullQuery = selectClause + fromClause + whereClause;
List<Case> cases = Database.query(fullQuery);
System.debug('Total number of cases: ' + cases.size());
for (Case c : cases) {
    System.debug(c);
}

// NOTE [SELECT Id, Status, Subject FROM Case WHERE RecordType.DeveloperName='Product_Support']
// is a valid alternative approach that uses the relationship to Record Type
