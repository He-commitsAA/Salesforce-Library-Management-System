import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import BRANCHSELECTEDMC from '@salesforce/messageChannel/BranchSelected__c';
import NAME_FIELD from '@salesforce/schema/Branch__c.Name';
import PHONE_NUMBER_FIELD from '@salesforce/schema/Branch__c.Phone__c';
import ADDRESS_FIELD from '@salesforce/schema/Branch__c.Address__c';

export default class BranchSummary extends NavigationMixin(LightningElement) {
    branchId;
    branchFields = [NAME_FIELD, PHONE_NUMBER_FIELD, ADDRESS_FIELD];
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {
        recordId: '$branchId',
        fields: [NAME_FIELD]
    })
    branch;

    @api
    get recordId() {
        return this.branchId;
    }

    set recordId(branchId) {
        this.branchId = branchId;
    }

    get branchName() {
        return getFieldValue(this.branch.data, NAME_FIELD);
    }

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            BRANCHSELECTEDMC,
            (message) => {
                this.handleBranchSelected(message);
            }
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleBranchSelected(message) {
        this.branchId = message.branchId;
    }

    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.branchId,
                objectApiName: 'Branch__c',
                actionName: 'view'
            }
        });
    }
}
