global class BookFlagger implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT name,flagged_for_removal__c,branch__c from book_copy__c WHERE condition__c LIKE \'damaged\' ORDER BY name';
        return Database.getQueryLocator(query);
    }
  

   global void execute(Database.BatchableContext BC, List<Book_Copy__c> bcs){

        for(Book_Copy__c bcopy: bcs){
            bcopy.flagged_for_removal__c = true;
        }
        update bcs;
        TaskCreator.createRemovalTask(bcs);

    }
  
   global void finish(Database.BatchableContext BC){

    Id librarianProfileId = [select id from profile where name like 'Librarian'].id;
    List<User> librarianUsers = [select email from user where profileid =: librarianProfileId];
    List<String> toAddresses = new List<String>();
    for(User u: librarianUsers){
        toAddresses.add(u.email);
    }

    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setSubject('New Books Flagged for Removal');
    mail.setSaveAsActivity(false);
    Id templateId= [SELECT id FROM EmailTemplate WHERE name LIKE 'Librarian Email Template'].id;
    mail.setTemplateId(templateId);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
   }

   global void execute(SchedulableContext sc) {
        BookFlagger bf = new BookFlagger ();
        database.executebatch(bf);
    }
}