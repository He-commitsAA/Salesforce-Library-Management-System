public with sharing class BranchHelper {
    
    public static Branch__c getBranch(){

        Id myUserId = UserInfo.getUserId();
        Contact c = [select branch__c from contact where Librarian_User__c =: myUserId limit 1];
        Branch__c myBranch = c.branch__c;
        return myBranch;

    }
}