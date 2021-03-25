import { LightningElement, wire, track } from 'lwc';
import getCheckedOutBooks from '@salesforce/apex/BookController.getCheckedOutBooks';
import getLoans from '@salesforce/apex/BookController.getLoans';
import getBookList from '@salesforce/apex/BookController.getBookList';
import getBorrowers from '@salesforce/apex/BookController.getBorrowers';
import renewLoan from '@salesforce/apex/BookController.renewLoan';

const extension = 14;

function addDays(date, days) {
    var result = new Date(date);
    result.setDate(result.getDate()+1 + days);
    return result;
}

export default class RenewBook extends LightningElement {
    @track loans;
    allLoans;
    copies;
    allBooks;
    borrowers;

    handleChange(event) {
        let searchQuery = event.target.value;
        //change shown loans to give best match to query by copy#, title, or borrower
        this.loans = [];
        for (let i in this.allLoans) {
            let l = this.allLoans[i];
            if (l.Title.toLowerCase().includes(searchQuery.toLowerCase()) || l.Serial.toLowerCase().includes(searchQuery.toLowerCase()) || l.Member.toLowerCase().includes(searchQuery.toLowerCase())) {
                this.loans.push(l);
            }
        }
    }

    renew(event) {
        //renew the book
        let loanId = event.target.name;
        renewLoan({ loanId: loanId, days: extension })
            .then(() => {
                let extendedDate = undefined;
                for (let i in this.allLoans) {
                    let loan = this.allLoans[i];
                    if (loan.Id === loanId) {
                        let newDate = addDays(loan.Due__c, extension);
                        let newMonth = (newDate.getMonth()+1).toString();
                        if (newMonth.length == 1) newMonth = '0' + newMonth;
                        let date = newDate.getDate().toString();
                        if (date.length == 1) date = '0' + date;
                        extendedDate = `${newDate.getFullYear()}-${newMonth}-${date}`;
                        this.allLoans[i].Due__c = extendedDate;
                        break;
                    }
                }
                for (let i in this.loans) {
                    let loan = this.loans[i];
                    if (loan.Id === loanId) {
                        this.loans[i].Due__c = extendedDate;
                        break;
                    }
                }
                this.loans = [...this.loans];
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
                Object.assign(this.allLoans[i], loan); //copy the entire list to allow for edits
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