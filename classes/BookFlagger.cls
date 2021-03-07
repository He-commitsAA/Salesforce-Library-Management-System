global inherited sharing class BookFlagger implements Schedulable {
    
    global void execute(SchedulableContext sc){

        flagOldBookCopies(Date.today().addYears(-10));
    }

    public void flagOldBookCopies(Date cutoff){

        List<Book_Copy__c> bcs = [select flagged_for_removal__c from book_copy__c where createddate <: cutoff OR condition__c like 'damaged'];
        for(Book_Copy__c bc: bcs){
            bc.flagged_for_removal__c = true;
        }
        update bcs;
    }
}
