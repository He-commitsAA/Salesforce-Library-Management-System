import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import returnBook from '@salesforce/apex/BookController.returnBook';

export default class ReturnBook extends LightningElement {
    bookNo;
    damaged;

    handleChange(event) {
        if (event.target.name === 'bookNo') {
            this.bookNo = event.target.value;
        }
    }

    handleCheckBoxChange(event){
        this.damaged = event.target.checked;
     }

    handleClick(event) {
        var toast;

        returnBook({bookNo: this.bookNo, damaged: this.damaged})
            .then(result => toast = new ShowToastEvent({
                title: 'Return Successful',
                message: result,
                variant: 'success'
            }))
            .catch(error => toast = new ShowToastEvent({
                title: 'Return Failed',
                message: this.damaged,
                variant: 'error'
            }))
            .finally(() => {
                this.dispatchEvent(toast);
                this.template.querySelectorAll('lightning-input').forEach(element => element.value = null);
            });
            
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.template.querySelector('lightning-button').click();
        }
    }
}