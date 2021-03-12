import { LightningElement, wire } from 'lwc';
import getCheckedOutBooks from '@salesforce/apex/BookController.getCheckedOutBooks';
import getLoans from '@salesforce/apex/BookController.getLoans';
import getBookList from '@salesforce/apex/BookController.getBookList';
import getBorrowers from '@salesforce/apex/BookController.getBorrowers';
import renewLoan from '@salesforce/apex/BookController.renewLoan';

const extension = 14;

export default class RenewBook extends LightningElement {
    loans;
    allLoans;
    copies;
    allBooks;
    borrowers;

    handleChange(event) {
        let searchQuery = event.target.value;
        //change shown loans to give best match to query by copy# or title
        this.loans = [];
        for (let i in this.allLoans) {
            let l = this.allLoans[i];
            if (l.Title.includes(searchQuery) || l.Serial.includes(searchQuery)) {
                this.loans.push(l);
            }
        }
    }

    renew(event) {
        //renew the book
        let loanId = event.target.name;
        console.log(loanId);
        renewLoan({ loanId: loanId, days: extension })
            .then(() => {
                //todo: update the local loan list
            }).catch((error) => {
                console.log(error);
            });
    }

    @wire(getBookList)
    wireAllBooks(result) {
        if (result) {
            this.allBooks = new Map();
            for (let i in result.data) {
                let book = result.data[i];
                this.allBooks.set(book.Id, book);
            }
        }
        else {
            this.allBooks = undefined;
        }
    }

    @wire(getCheckedOutBooks)
    wireCopies(result) {
        if (result) {
            this.copies = new Map();
            for (let i in result.data) {
                let copy = result.data[i];
                this.copies.set(copy.Id, copy);
            }
        }
        else {
            this.copies = undefined;
        }
    }

    @wire(getBorrowers)
    wireBorrowers(result) {
        if (result) {
            this.borrowers = new Map();
            for (let i in result.data) {
                let bor = result.data[i];
                this.borrowers.set(bor.Id, bor);
            }
        }
        else {
            this.borrowers = undefined;
        }
    }

    @wire(getLoans)
    wireLoans(result) {
        if (result) {
            this.allLoans = [];
            for (let i in result.data) {
                let loan = result.data[i];
                this.allLoans.push({});
                Object.assign(this.allLoans[i], loan);
                let copy = this.copies.get(loan.Book_Copy__c);
                this.allLoans[i].Serial = copy.Name;
                this.allLoans[i].Title = this.allBooks.get(copy.Book__c).Name;
                this.allLoans[i].Member = this.borrowers.get(loan.Borrower__c).Name;
            }
        }
        else {
            this.allLoans = undefined;
        }
    }
}