import Foundation

// MARK: - Entities

struct Author: Codable, Identifiable {
    let id: String              // author_id
    var firstName: String
    var lastName: String
    var birthYear: Int?         // NULLable in ERD
    
    // 1:M Author → Book 
    var books: [Book]?          // populated in sample data
}

struct Book: Codable, Identifiable {
    let id: String              // book_id
    let authorID: String        // FK → Author.id
    var isbn: String
    var title: String
    var publishedYear: Int?
    
    // 1:M Book → Copy
    var copies: [Copy]?         // populated in sample data
}

enum CopyStatus: String, Codable {
    case active, lost, repair
}

struct Copy: Codable, Identifiable {
    let id: String              // copy_id
    let bookID: String          // FK → Book.id
    var barcode: String
    var acquiredDate: Date
    var status: CopyStatus
}

struct Member: Codable, Identifiable {
    let id: String              // member_id
    var firstName: String
    var lastName: String
    var email: String
    var joinedDate: Date
    
    // 1:M Member → Loan
    var loans: [Loan]?          // populated in sample data
}

struct Loan: Codable, Identifiable {
    let id: String              // loan_id
    
    //Loan references both Book and Member
    let bookID: String          // FK → Book.id
    let memberID: String        // FK → Member.id
    
    var loanDate: Date
    var dueDate: Date
    var returnDate: Date?       // optional (NULL in ERD)
    
    // Optional object references
    var book: Book?
    var member: Member?
}

// MARK: - Sample Data (2 authors, 2 books, 2 members, 4 loans)

func makeDate(_ iso: String) -> Date {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withFullDate]
    return f.date(from: iso)!
}

struct LibraryData: Codable {
    var authors: [Author]
    var books: [Book]
    var copies: [Copy]
    var members: [Member]
    var loans: [Loan]
    
    static func sample() -> LibraryData {
        // Authors
        var a1 = Author(id: "A-01", firstName: "Harper", lastName: "Lee", birthYear: 1926, books: nil)
        var a2 = Author(id: "A-02", firstName: "George", lastName: "Orwell", birthYear: 1903, books: nil)
        
        // Books
        var b1 = Book(id: "B-01", authorID: a1.id, isbn: "9780061120084", title: "To Kill a Mockingbird", publishedYear: 1960, copies: nil)
        var b2 = Book(id: "B-02", authorID: a2.id, isbn: "9780451524935", title: "1984",                     publishedYear: 1949, copies: nil)
        
        // Copies
        let c1 = Copy(id: "C-01", bookID: b1.id, barcode: "BC-0001", acquiredDate: makeDate("2023-01-15"), status: .active)
        let c2 = Copy(id: "C-02", bookID: b1.id, barcode: "BC-0002", acquiredDate: makeDate("2023-06-01"), status: .active)
        let c3 = Copy(id: "C-03", bookID: b2.id, barcode: "BC-0003", acquiredDate: makeDate("2022-11-20"), status: .active)
        let c4 = Copy(id: "C-04", bookID: b2.id, barcode: "BC-0004", acquiredDate: makeDate("2024-02-10"), status: .repair)
        
        // Members
        var m1 = Member(id: "M-01", firstName: "Ava",  lastName: "Nguyen", email: "ava@example.com",  joinedDate: makeDate("2022-09-05"), loans: nil)
        var m2 = Member(id: "M-02", firstName: "Liam", lastName: "Patel",  email: "liam@example.com", joinedDate: makeDate("2023-03-12"), loans: nil)
        
        // Loans (4)
        var l1 = Loan(
            id: "L-01",
            bookID: b1.id, memberID: m1.id,
            loanDate: makeDate("2024-09-01"),
            dueDate:  makeDate("2024-09-21"),
            returnDate: makeDate("2024-09-18"),
            book: b1, member: m1
        )
        var l2 = Loan(
            id: "L-02",
            bookID: b2.id, memberID: m1.id,
            loanDate: makeDate("2024-10-03"),
            dueDate:  makeDate("2024-10-24"),
            returnDate: nil,
            book: b2, member: m1
        )
        var l3 = Loan(
            id: "L-03",
            bookID: b1.id, memberID: m2.id,
            loanDate: makeDate("2024-11-10"),
            dueDate:  makeDate("2024-12-01"),
            returnDate: nil,
            book: b1, member: m2
        )
        var l4 = Loan(
            id: "L-04",
            bookID: b2.id, memberID: m2.id,
            loanDate: makeDate("2024-11-20"),
            dueDate:  makeDate("2024-12-11"),
            returnDate: nil,
            book: b2, member: m2
        )
        
        // Hook up 1:M arrays on the “one” side for clarity
        b1.copies = [c1, c2]
        b2.copies = [c3, c4]
        
        a1.books = [b1]
        a2.books = [b2]
        
        m1.loans = [l1, l2]
        m2.loans = [l3, l4]
        
        // Return the full graph
        return LibraryData(
            authors: [a1, a2],
            books:   [b1, b2],
            copies:  [c1, c2, c3, c4],
            members: [m1, m2],
            loans:   [l1, l2, l3, l4]
        )
    }
}
