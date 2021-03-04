trigger LoanTrigger on Loan__c (before insert) {

    if(Trigger.isInsert){
        LoanDateFiller.fillDates(Trigger.new);
    }
}