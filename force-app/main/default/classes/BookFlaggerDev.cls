public class BookFlaggerDev {


    public void flagOldBookCopies(Date cutoff){

        List<Book_Copy__c> bcs = [select createddate,flagged_for_removal__c from book_copy__c where createddate <: cutoff];
        for(Book_Copy__c bc: bcs){
            bc.flagged_for_removal__c = true;
        }
        update bcs;
    }
}