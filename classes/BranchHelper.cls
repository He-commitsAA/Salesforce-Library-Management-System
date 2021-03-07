global with sharing class BranchHelper {
    
    global static Branch__c getBranch(){

        Id myUserId = UserInfo.getUserId();
        Contact c = [select branch__c from contact where Librarian_User__c =: myUserId limit 1].get(0);
        Branch__c myBranch = [select name from branch__c where id =: c.branch__c limit 1].get(0);
        return myBranch;

    }
}