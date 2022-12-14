global class CandidatePositionEmailHandler implements Messaging.InboundEmailHandler { 
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) { 
        // declare the result variable 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
        // declare a string variable to catch our custom debugging messages 
        String myErr; 
        try{ 
            // extract the email body : either the htmlBody or the plainTextBody 
            String theBody; 
            List<String> fieldList = new List<String>(); 
            if (email.plainTextBody != null){ 
                myErr = 'plainTextBody=' + email.plainTextBody; 
                theBody = email.plainTextBody; 
                
            } else { 
                myErr = 'htmlBody=' + email.htmlBody; 
                theBody = email.htmlBody; 
            } 
            
            System.debug('Recevied email with body: '); 
            System.debug(theBody); 
            
            // parse the body by the expected delimiters 
            theBody = theBody.substring(theBody.indexOf('[STARTBODY]')+11,theBody.indexOf('[ENDBODY]')); 
            fieldList = theBody.split(':',0); 
            // record the values in myErr in case of an Exception somewhere 
            myErr += '\ntheBody=' + theBody; 
            myErr += '\nfieldList=' + fieldList; 
            
            // create a Map for the field values: key=field name, value=field value 
            Map<String,String> fieldMap = new Map<String,String>(); 
            for(String field : fieldList){ 
                // the email contains name/value pairs like "firstname=mike", split them up 
                // and if a value is present then add that field to the Map 
                if (field.split('=',0).size() == 2){ 
                    fieldMap.put((String)(field.split('=',0)[0]).toLowerCase(),field.split('=',0)[1]); 
                } 
            } 
            
            // check for a matching candidate in the DB based on lastname + email 
            Candidate__c candidate; 
            try{ 
                candidate = [select id,first_name__c,last_name__c,phone__c,email__c,ownerid from candidate__c where last_name__c =:fieldMap.get('lastname') and email__c =:fieldMap.get('email')]; 
            } catch (QueryException qe){ 
                if (candidate == null){ 
                    candidate = new Candidate__c(); 
                } 
                // continue on...don't throw an error nor return result...we've handled the error we were expecting 
            } 
            // update or insert the field values that came in the email 
            candidate.first_name__c = fieldMap.containsKey('firstname') ? EncodingUtil.urlDecode(fieldMap.get('firstname'),'UTF-8') : null; 
            candidate.last_name__c = fieldMap.containsKey('lastname') ? EncodingUtil.urlDecode(fieldMap.get('lastname'),'UTF-8') : null; 
            candidate.email__c = fieldMap.containsKey('email') ? EncodingUtil.urlDecode(fieldMap.get('email'),'UTF-8') : null; 
            candidate.phone__c = fieldMap.containsKey('phone') ? EncodingUtil.urlDecode(fieldMap.get('phone'),'UTF-8') : null; 
            
            
            try{ 
                if (candidate.id == null) { 
                    insert candidate; 
                } else { 
                    update candidate; 
                } 
            } catch (DMLException e){ 
                // To keep a record of errors we've created a custom object called Error_Log__c for logging purposes 
                // -Remember to clean out old log records regularly so as not to use up valuable storage 
                Error_Log__c log = new Error_Log__c(); 
                log.trace__c = e.getTypeName() + '\n' + e.getCause() + '\n' + e.getMessage() + '\n\nfieldMap=' + fieldMap + '\n\nmyErr=' + myErr; 
                insert log; 
                // return false 
                result.success = false; 
                return result; 
            } 
            
            // create a new Note on the candidate containing the email comment 
            if (fieldMap.containsKey('comment')){ 
                Note cNote = new Note(); 
                cNote.body = EncodingUtil.urlDecode(fieldMap.get('comment'),'UTF-8'); 
                cNote.parentId = candidate.id; 
                cNote.title = 'CandidateEmail:' + System.now(); 
                try{ 
                    insert cNote; 
                } catch (DMLException e){ 
                    Error_Log__c log = new Error_Log__c(); 
                    log.trace__c = e.getTypeName() + '\n' + e.getCause() + '\n' + e.getMessage() + '\n\nfieldMap=' + fieldMap + '\n\nmyErr=' + myErr; 
                    insert log; 
                    result.success = false; 
                    return result; 
                } 
            } 
            
            // create a new attachment 
            // attachment may be text or binary 
            List<Attachment> attachments = new List<Attachment>(); 
            if (email.binaryAttachments != null){ 
                for (Messaging.InboundEmail.BinaryAttachment emailAttachment:email.binaryAttachments){ 
                    Attachment attachment = new Attachment(); 
                    attachment.parentId = candidate.id; 
                    attachment.body = emailAttachment.body; 
                    attachment.name = emailAttachment.fileName; 
                    attachments.add(attachment); 
                } 
            } 
            if (email.textAttachments != null){ 
                for (Messaging.InboundEmail.TextAttachment emailAttachment:email.textAttachments){ 
                    Attachment attachment = new Attachment(); 
                    attachment.parentId = candidate.id; 
                    attachment.body = blob.valueOf(emailAttachment.body); 
                    attachment.name = emailAttachment.fileName; 
                    attachments.add(attachment); 
                } 
            } 
            // insert the attachments 
            if (attachments.size() > 0){ 
                try{ 
                    insert attachments; 
                } catch (DMLException e){ 
                    Error_Log__c log = new Error_Log__c(); 
                    log.trace__c = e.getTypeName() + '\n' + e.getCause() + '\n' + e.getMessage() + '\n\nfieldMap=' + fieldMap + '\n\nmyErr=' + myErr; 
                    insert log; 
                    result.success = false; 
                    return result; 
                } 
            } 
            
            // now create the application against the specified position 
            Job_Application__c application; 
            
            // populate the fields on the applciation 
            application = new Job_Application__c(Candidate__c=candidate.id,Position__c=EncodingUtil.urlDecode(fieldMap.get('position'),'UTF-8')); 
            
            try{ 
                insert application; 
            } catch (DMLException e){ 
                // To keep a record of errors we've created a custom object called Error_Log__c for logging purposes 
                // -Remember to clean out old log records regularly so as not to use up valuable storage 
                Error_Log__c log = new Error_Log__c(); 
                log.trace__c = e.getTypeName() + '\n' + e.getCause() + '\n' + e.getMessage() + '\n\nfieldMap=' + fieldMap + '\n\nmyErr=' + myErr; 
                insert log; 
                // return false 
                result.success = false; 
                return result; 
            } 
            
        } catch (Exception e){ 
            Error_Log__c log = new Error_Log__c(); 
            log.trace__c = e.getTypeName() + '\n' + e.getCause() + '\n' + e.getMessage() + '\n\nmyErr=' + myErr; 
            insert log; 
            
            result.success = false; 
            result.message = e.getTypeName() + '\n' + e.getCause() + '\n' + e.getMessage() + '\n\nmyErr=' + myErr; 
            return result; 
        } 
        
        return result; 
    } 
}