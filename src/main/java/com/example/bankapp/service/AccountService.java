package com.example.bankapp.service;

import com.example.bankapp.model.Account;
import com.example.bankapp.model.Transaction;
import com.example.bankapp.repository.AccountRepository;
import com.example.bankapp.repository.TransactionRepository;
import com.example.bankapp.security.AuthenticatedUser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.regex.Pattern;

@Service
public class AccountService implements UserDetailsService {

    private static final Pattern USERNAME_PATTERN = Pattern.compile("[A-Za-z0-9._-]{3,50}");
    private static final BigDecimal MAX_BALANCE = new BigDecimal("99999999999999999.99");
    private static final int TRANSACTION_PAGE_SIZE = 25;

    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final BigDecimal maxTransactionAmount;

    public AccountService(AccountRepository accountRepository,
                          TransactionRepository transactionRepository,
                          PasswordEncoder passwordEncoder,
                          @Value("${bankapp.max-transaction-amount:1000000.00}")
                          BigDecimal maxTransactionAmount) {
        this.accountRepository = accountRepository;
        this.transactionRepository = transactionRepository;
        this.passwordEncoder = passwordEncoder;
        this.maxTransactionAmount = maxTransactionAmount;
    }

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Account account = findAccount(normalizeUsername(username));
        return new AuthenticatedUser(account.getId(), account.getUsername(), account.getPassword());
    }

    public String registerAccount(String username, String password) {
        String normalizedUsername = normalizeUsername(username);
        String validationError = validateRegistration(normalizedUsername, password);
        if (validationError != null) {
            return validationError;
        }
        if (accountRepository.existsByUsername(normalizedUsername)) {
            return "Username is already taken.";
        }

        try {
            accountRepository.saveAndFlush(
                new Account(normalizedUsername, passwordEncoder.encode(password))
            );
            return null;
        } catch (DataIntegrityViolationException exception) {
            // The unique constraint is the final guard against concurrent registrations.
            return "Username is already taken.";
        }
    }

    @Transactional(readOnly = true)
    public Account getAccount(String username) {
        return findAccount(normalizeUsername(username));
    }

    @Transactional
    public String deposit(String username, BigDecimal requestedAmount) {
        AmountValidation amount = validateAmount(requestedAmount);
        if (amount.error() != null) {
            return amount.error();
        }

        Account account = lockAccount(normalizeUsername(username));
        BigDecimal newBalance = account.getBalance().add(amount.value());
        if (newBalance.compareTo(MAX_BALANCE) > 0) {
            return "Account balance limit exceeded.";
        }

        account.setBalance(newBalance);
        transactionRepository.save(new Transaction(
            amount.value(), "Deposit", LocalDateTime.now(ZoneOffset.UTC), account
        ));
        return null;
    }

    @Transactional
    public String withdraw(String username, BigDecimal requestedAmount) {
        AmountValidation amount = validateAmount(requestedAmount);
        if (amount.error() != null) {
            return amount.error();
        }

        Account account = lockAccount(normalizeUsername(username));
        if (account.getBalance().compareTo(amount.value()) < 0) {
            return "Insufficient funds.";
        }

        account.setBalance(account.getBalance().subtract(amount.value()));
        transactionRepository.save(new Transaction(
            amount.value(), "Withdrawal", LocalDateTime.now(ZoneOffset.UTC), account
        ));
        return null;
    }

    @Transactional
    public String transferAmount(String fromUsername, String requestedRecipient,
                                 BigDecimal requestedAmount) {
        AmountValidation amount = validateAmount(requestedAmount);
        if (amount.error() != null) {
            return amount.error();
        }

        String sourceUsername = normalizeUsername(fromUsername);
        String recipientUsername = normalizeUsername(requestedRecipient);
        if (recipientUsername == null || !USERNAME_PATTERN.matcher(recipientUsername).matches()) {
            return "Recipient not found.";
        }
        if (sourceUsername.equalsIgnoreCase(recipientUsername)) {
            return "Cannot transfer to yourself.";
        }

        // Lock in a stable order so opposite-direction transfers cannot deadlock.
        String firstUsername = sourceUsername.compareTo(recipientUsername) < 0
            ? sourceUsername : recipientUsername;
        String secondUsername = firstUsername.equals(sourceUsername)
            ? recipientUsername : sourceUsername;

        Account first = accountRepository.findByUsernameForUpdate(firstUsername).orElse(null);
        if (first == null) {
            return "Recipient not found.";
        }
        Account second = accountRepository.findByUsernameForUpdate(secondUsername).orElse(null);
        if (second == null) {
            return "Recipient not found.";
        }

        Account source = sourceUsername.equals(firstUsername) ? first : second;
        Account recipient = recipientUsername.equals(firstUsername) ? first : second;
        if (source.getId().equals(recipient.getId())) {
            return "Cannot transfer to yourself.";
        }

        if (source.getBalance().compareTo(amount.value()) < 0) {
            return "Insufficient funds.";
        }
        if (recipient.getBalance().add(amount.value()).compareTo(MAX_BALANCE) > 0) {
            return "Recipient balance limit exceeded.";
        }

        source.setBalance(source.getBalance().subtract(amount.value()));
        recipient.setBalance(recipient.getBalance().add(amount.value()));

        LocalDateTime now = LocalDateTime.now(ZoneOffset.UTC);
        transactionRepository.save(new Transaction(amount.value(), "Transfer Out", now, source));
        transactionRepository.save(new Transaction(amount.value(), "Transfer In", now, recipient));
        return null;
    }

    @Transactional(readOnly = true)
    public Page<Transaction> getTransactionHistory(String username, int page) {
        Account account = findAccount(normalizeUsername(username));
        return transactionRepository.findByAccountIdOrderByTimestampDesc(
            account.getId(), PageRequest.of(Math.max(page, 0), TRANSACTION_PAGE_SIZE)
        );
    }

    @Transactional(readOnly = true)
    public List<Transaction> getRecentTransactions(String username) {
        Account account = findAccount(normalizeUsername(username));
        return transactionRepository.findTop5ByAccountIdOrderByTimestampDesc(account.getId());
    }

    private String validateRegistration(String username, String password) {
        if (username == null || !USERNAME_PATTERN.matcher(username).matches()) {
            return "Username must be 3-50 characters and use only letters, numbers, dot, dash, or underscore.";
        }
        if (password == null || password.length() < 12) {
            return "Password must be at least 12 characters.";
        }
        if (password.getBytes(StandardCharsets.UTF_8).length > 72) {
            return "Password must be at most 72 UTF-8 bytes.";
        }
        return null;
    }

    private AmountValidation validateAmount(BigDecimal amount) {
        if (amount == null || amount.signum() <= 0) {
            return AmountValidation.invalid("Amount must be greater than zero.");
        }
        try {
            BigDecimal normalized = amount.setScale(2, RoundingMode.UNNECESSARY);
            if (normalized.compareTo(maxTransactionAmount) > 0) {
                return AmountValidation.invalid(
                    "Amount exceeds the per-transaction limit of " + maxTransactionAmount + "."
                );
            }
            return new AmountValidation(normalized, null);
        } catch (ArithmeticException exception) {
            return AmountValidation.invalid("Amount must have no more than two decimal places.");
        }
    }

    private Account findAccount(String username) {
        return accountRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("Account not found"));
    }

    private Account lockAccount(String username) {
        return accountRepository.findByUsernameForUpdate(username)
            .orElseThrow(() -> new UsernameNotFoundException("Account not found"));
    }

    private String normalizeUsername(String username) {
        return username == null ? null : username.trim();
    }

    private record AmountValidation(BigDecimal value, String error) {
        private static AmountValidation invalid(String error) {
            return new AmountValidation(null, error);
        }
    }
}
