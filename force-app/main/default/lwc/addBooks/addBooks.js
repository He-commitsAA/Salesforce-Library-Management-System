import { LightningElement, api } from 'lwc';
import addBooks from '@salesforce/apex/BookController.addBooks';

export default class AddBooks extends LightningElement {
    addSuccessful;
    quantity;
    @api recordId;

    handleChange(event) {
        event.target.value = Math.floor(Math.abs(event.target.value));
        this.quantity = event.target.value;
    }

    createRecords() {
        this.addSuccessful = false;
        addBooks({ bookId: this.recordId, quantity: this.quantity })
            .then(() => {
                this.addSuccessful = true;
            }).catch(() => {
                this.addSuccessful = false;
            });
    }
}