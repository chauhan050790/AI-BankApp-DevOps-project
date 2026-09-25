package com.example.bankapp.service;

import com.example.bankapp.model.Account;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AccountServiceIntegrationTests {

    private static final String VALID_PASSWORD = "correct-horse-battery-staple";

    @Autowired
    private AccountService accountService;

    @Test
    void rejectsInvalidRegistrationData() {
        assertThat(accountService.registerAccount("x", VALID_PASSWORD))
            .contains("Username must be");
        assertThat(accountService.registerAccount("valid-user", "short"))
            .contains("at least 12");
    }

    @Test
    void rejectsInvalidAmountsWithoutChangingTheBalance() {
        assertThat(accountService.registerAccount("alice", VALID_PASSWORD)).isNull();

        assertThat(accountService.deposit("alice", new BigDecimal("-10.00")))
            .isEqualTo("Amount must be greater than zero.");
        assertThat(accountService.withdraw("alice", BigDecimal.ZERO))
            .isEqualTo("Amount must be greater than zero.");
        assertThat(accountService.deposit("alice", new BigDecimal("1.001")))
            .isEqualTo("Amount must have no more than two decimal places.");

        assertThat(accountService.getAccount("alice").getBalance())
            .isEqualByComparingTo("0.00");
        assertThat(accountService.getTransactionHistory("alice", 0)).isEmpty();
    }

    @Test
    void transfersMoneyAndCreatesAnAuditEntryForBothAccounts() {
        assertThat(accountService.registerAccount("alice", VALID_PASSWORD)).isNull();
        assertThat(accountService.registerAccount("bob", VALID_PASSWORD)).isNull();
        assertThat(accountService.deposit("alice", new BigDecimal("100.00"))).isNull();

        assertThat(accountService.transferAmount("alice", "bob", new BigDecimal("40.00")))
            .isNull();

        Account alice = accountService.getAccount("alice");
        Account bob = accountService.getAccount("bob");
        assertThat(alice.getBalance()).isEqualByComparingTo("60.00");
        assertThat(bob.getBalance()).isEqualByComparingTo("40.00");
        assertThat(accountService.getTransactionHistory("alice", 0)).hasSize(2);
        assertThat(accountService.getTransactionHistory("bob", 0)).hasSize(1);
    }

    @Test
    void rejectsSelfTransferRegardlessOfUsernameCase() {
        assertThat(accountService.registerAccount("alice", VALID_PASSWORD)).isNull();
        assertThat(accountService.deposit("alice", new BigDecimal("10.00"))).isNull();

        assertThat(accountService.transferAmount("alice", "ALICE", new BigDecimal("1.00")))
            .isEqualTo("Cannot transfer to yourself.");
        assertThat(accountService.getAccount("alice").getBalance())
            .isEqualByComparingTo("10.00");
    }
}
