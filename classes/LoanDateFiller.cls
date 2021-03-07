public with sharing class LoanDateFiller {
    
    public static void fillDates(List<Loan__c> loans){
        for(Loan__c loan: loans){
            loan.checkout__c = Date.today();
            loan.due__c = Date.today().addDays(14);
        }
    }
}
