/// The word the user types to confirm deleting their account.
const kDeleteConfirmWord = 'DELETE';

bool isDeleteConfirmed(String typed) => typed.trim().toUpperCase() == kDeleteConfirmWord;
