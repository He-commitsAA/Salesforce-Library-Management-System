global class BookFlagger implements Database.Batchable<sObject>, Schedulable {


    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT flagged_for_removal__c from book_copy__c WHERE createddate <: cutoff OR condition__c LIKE \'damaged\'';
        return Database.getQueryLocator(query);
    }
  

   global void execute(Database.BatchableContext BC, List<Book_Copy__c> bcs){

        Date cutoff = Date.today().addYears(-25);
        for(Book_Copy__c bcopy: bcs){
            bcopy.flagged_for_removal__c = true;
        }
        update bcs;


    }
  
   global void finish(Database.BatchableContext BC){

   }

   global void execute(SchedulableContext sc) {
        BookFlagger bf = new BookFlagger ();
        database.executebatch(bf);
    }
}