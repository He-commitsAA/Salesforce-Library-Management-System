import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkoutBook from '@salesforce/apex/BookController.checkoutBook';

export default class CheckoutBook extends LightningElement {
    bookNo;
    cardNo;

    handleChange(event) {
        if (event.target.name === 'bookNo') {
            this.bookNo = event.target.value;
        } else if (event.target.name === 'cardNo') {
            this.cardNo = event.target.value;
        }
    }

    handleClick(event) {
        var toast;

        checkoutBook({bookNo: this.bookNo, cardNo: this.cardNo})
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