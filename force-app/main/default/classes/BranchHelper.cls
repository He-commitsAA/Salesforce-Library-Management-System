global with sharing class BranchHelper {
    
    global static Branch__c getBranch(){
        Id myUserId = UserInfo.getUserId();
        Librarian__c l = [SELECT Branch__r.Id, Branch__r.Name FROM Librarian__c WHERE User__c = :myUserId LIMIT 1];
        return l.Branch__r;
    }
}