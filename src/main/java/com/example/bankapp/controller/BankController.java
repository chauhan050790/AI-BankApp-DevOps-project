package com.example.bankapp.controller;

import com.example.bankapp.model.Transaction;
import com.example.bankapp.security.AuthenticatedUser;
import com.example.bankapp.service.AccountService;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Controller
public class BankController {

    private final AccountService accountService;

    public BankController(AccountService accountService) {
        this.accountService = accountService;
    }

    @GetMapping("/")
    public String home() {
        return "redirect:/dashboard";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }

    @PostMapping("/register")
    public String register(@RequestParam String username,
                           @RequestParam String password,
                           Model model) {
        String error = accountService.registerAccount(username, password);
        if (error == null) {
            return "redirect:/login?registered";
        }
        model.addAttribute("error", error);
        model.addAttribute("username", username == null ? "" : username.trim());
        return "register";
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal AuthenticatedUser user, Model model) {
        model.addAttribute("account", accountService.getAccount(user.getUsername()));
        return "dashboard";
    }

    @PostMapping("/deposit")
    public String deposit(@AuthenticationPrincipal AuthenticatedUser user,
                          @RequestParam String amount,
                          RedirectAttributes redirectAttributes) {
        addResultMessage(
            accountService.deposit(user.getUsername(), parseAmount(amount)),
            "Deposit completed.", redirectAttributes
        );
        return "redirect:/dashboard";
    }

    @PostMapping("/withdraw")
    public String withdraw(@AuthenticationPrincipal AuthenticatedUser user,
                           @RequestParam String amount,
                           RedirectAttributes redirectAttributes) {
        addResultMessage(
            accountService.withdraw(user.getUsername(), parseAmount(amount)),
            "Withdrawal completed.", redirectAttributes
        );
        return "redirect:/dashboard";
    }

    @PostMapping("/transfer")
    public String transfer(@AuthenticationPrincipal AuthenticatedUser user,
                           @RequestParam String toUsername,
                           @RequestParam String amount,
                           RedirectAttributes redirectAttributes) {
        addResultMessage(
            accountService.transferAmount(user.getUsername(), toUsername, parseAmount(amount)),
            "Transfer completed.", redirectAttributes
        );
        return "redirect:/dashboard";
    }

    @GetMapping("/transactions")
    public String transactions(@AuthenticationPrincipal AuthenticatedUser user,
                               @RequestParam(defaultValue = "0") int page,
                               Model model) {
        Page<Transaction> transactionPage = accountService.getTransactionHistory(
            user.getUsername(), page
        );
        model.addAttribute("transactions", transactionPage.getContent());
        model.addAttribute("transactionPage", transactionPage);
        return "transactions";
    }

    private BigDecimal parseAmount(String value) {
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException | NullPointerException exception) {
            return null;
        }
    }

    private void addResultMessage(String error, String success,
                                  RedirectAttributes redirectAttributes) {
        if (error == null) {
            redirectAttributes.addFlashAttribute("success", success);
        } else {
            redirectAttributes.addFlashAttribute("error", error);
        }
    }
}
