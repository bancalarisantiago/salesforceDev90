public with sharing class DisplayContacts_CC {

    /**
     *      This custom controller is used to do a wildcard
     *      SOSL search across all fields for Contacts.
     *      Use a StandardSetController to handle pagination
     *      and potentially a large set of records
     */

    /** TODO #1: Declare a property whose type is String named searchText.
     *           The getter should return the searchText property and the
     *           setter should assign the searchText property the implicit
     *           argument called value.
     */
    public String searchText {
        get {
            return searchText;
        }
        set {
            searchtext = value;
        }
    }

    // Indicates whether records were found
    public Boolean matches {
        get {
            return ( (contacts != null) && (contacts.size() != 0) );
        }
        set;
    }

    public Boolean searched {get; set;}                             // Indicates whether search has been done
    public ApexPages.StandardSetController setCon { get; set; }     // Standard Set Controller

    // Constructor
    public DisplayContacts_CC() {
        searched=false;
    }

    // List of Contacts displayed on the page
    public List<Contact> contacts {
        get {
            if (setCon != null ) {
                return (List<Contact>)setCon.getRecords();
            } else {
                return null;
            }
        }
        set;
    }

    // Action method initiated by user
    public void Search() {

        if (String.isNotBlank(searchText) && searchtext.length() > 1) {
            /** TODO #2: Add code within the if statement that will:
             *  -- Concatenate a wildcard to the end of the searchText property if it does not already end with one
             *            -- Declare a variable whose type is a List of sObject named
             *               contacts that will be assigned to the position zero result
             *               of a SOSL search that:
             *               -- finds the value from the dynamically bound searchText property
             *               -- in all fields
             *               -- returning the Id, Name, Email, Phone, Account.Name from Contact
             *            -- Assign the setCon property the result of constructing a
             *               ApexPages.StandardSetController class passing in contacts.
             *            -- Assign the searched property a value of true
             */
            if (!searchText.endsWith('*')) {
                searchText = searchText + '*';
            }
            // The above if statement could have been written with the ternary operator as follows:
            // searchText = ( searchText.endsWith('*') ? searchText : (searchText + '*') ); 

            List<sObject> contacts = [FIND :searchText
                                      IN ALL FIELDS
                                      RETURNING Contact (Id, Name, Email, Phone, Account.Name)][0];

            setCon = new ApexPages.StandardSetController(contacts);
            setCon.setPageNumber(1);
            setCon.setPageSize(10);

            searched = true;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                      'Please enter search text at least two characters long'));
        }
    }
}