global class OverdueReminder implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        List<AggregateResult> overdueLoans = [SELECT Borrower__c FROM Loan__c WHERE overdue__c = TRUE GROUP BY Borrower__c];
        List<id> overdueBorrowerIds = new List<id>();

        for(AggregateResult agg: overdueLoans){
            overdueBorrowerIds.add((id)agg.get('Borrower__c'));
        }

        String query = 'SELECT id,email FROM Contact WHERE id IN :overdueBorrowerIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> overdueBorrowers){

        for(Contact c: overdueBorrowers){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add(c.email);
            mail.setToAddresses(toAddresses);
            mail.setSaveAsActivity(false);
            EmailTemplate overdueTemplate = [SELECT id,subject,htmlValue FROM EmailTemplate WHERE name LIKE 'Overdue Notice'];
            mail.setTemplateId(overdueTemplate.id);
            mail.setTargetObjectId(c.id);
            mail.setWhatId(c.id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    global void finish(Database.BatchableContext BC){}

    global void execute(SchedulableContext sc) {
        OverdueReminder reminder = new OverdueReminder ();
        database.executebatch(reminder);
    }


}
