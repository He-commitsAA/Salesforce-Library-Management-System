import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'
import checkoutBook from '@salesforce/apex/BookController.checkoutBook';
import renewBook from '@salesforce/apex/BookController.renewBook';
import returnBook from '@salesforce/apex/BookController.returnBook';

const FIELDS = [
    'Book_Copy__c.Id',
    'Book_Copy__c.Name',
    'Book_Copy__c.Borrower__r.Name',
    'Book_Copy__c.Branch__r.Name'
];

export default class BookCopyManagement extends LightningElement {
    @api recordId;

    cardNo;

    damaged = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    bookCopy;

    get bookCopyId() {
        return this.bookCopy.data.fields.Id.value;
    }

    get bookNo() {
        return this.bookCopy.data.fields.Name.value;
    }

    get borrowerName() {
        if (this.bookCopy.data.fields.Borrower__r.value) {
            return this.bookCopy.data.fields.Borrower__r.value.fields.Name.value;
        } else {
            return null;
        }
    }

    get branchName() {
        if (this.bookCopy.data.fields.Branch__r.value) {
            return this.bookCopy.data.fields.Branch__r.value.fields.Name.value;
        } else {
            return null;
        }
    }

    get title() {
        if (this.borrowerName) {
            return 'Renew/Return Book';
        } else if (this.branchName) {
            return 'Checkout Book';
        } else {
            return 'Book Copy Actions';
        }
    }

    get message() {
        if (this.borrowerName) {
            return `This book is loaned out to ${this.borrowerName}.`;
        } else if (this.branchName) {
            return `This book is currently at ${this.branchName}.`;
        } else {
            return 'Please put in a branch or borrower for this book copy.';
        }
    }

    toggleDamaged(event) {
        this.damaged = event.target.value;
    }

    setCardNo(event) {
        this.cardNo = event.target.value;
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.template.querySelector('lightning-button').click();
        }
    }

    checkoutBook() {
        var toast;

        checkoutBook({ bookNo: this.bookNo, cardNo: this.cardNo })
            .then(result => toast = new ShowToastEvent({
                title: 'Checkout Successful',
                message: result,
                variant: 'success'
            }))
            .catch(error => toast = new ShowToastEvent({
                title: 'Checkout Failed',
                message: error.body.message,
                variant: 'error'
            }))
            .finally(() => {
                this.template.querySelectorAll('lightning-input').forEach(element => element.value = null);
                this.dispatchEvent(toast);
                refreshApex(this.bookCopy);
            });
    }

    renewBook() {
        var toast;

        renewBook({ bookCopyId: this.bookCopyId })
            .then(newDate => toast = new ShowToastEvent({
                title: 'Renew Successful',
                message: `Now due ${newDate}`,
                variant: 'success'
            }))
            .catch(error => toast = new ShowToastEvent({
                title: 'Renew Failed',
                message: error.body.message,
                variant: 'error'
            }))
            .finally(() => {
                this.dispatchEvent(toast);
            })
    }

    returnBook() {
        var toast;

        returnBook({bookNo: this.bookNo, damaged: this.damaged})
            .then(result => toast = new ShowToastEvent({
                title: 'Return Successful',
                message: result,
                variant: 'success'
            }))
            .catch(error => toast = new ShowToastEvent({
                title: 'Return Failed',
                message: error.body.message,
                variant: 'error'
            }))
            .finally(() => {
                this.template.querySelectorAll('lightning-input').forEach(element => element.value = null);
                this.dispatchEvent(toast);
                refreshApex(this.bookCopy);
            });
    }
}