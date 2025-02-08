class InvestmentsController < ApplicationController
  def index
    @accounts = BankAccount.all
  end

  def calculate
    # debugger
    @amount = params[:amount].to_f
    @accounts = BankAccount.all
    @adjustments = []
    remaining_amount = @amount

    # debugger
    # Step 1: Deduct from the account which match the exact amount
    if (account = find_exact_match(remaining_amount))
      adjust(account, remaining_amount)
      remaining_amount = 0
    end

    # Step 2: Deduct from the account which is greater than the invested amount
    if remaining_amount.positive? && (account = find_greater_balance(remaining_amount))
      adjust(account, remaining_amount)
      remaining_amount = 0
    end

    # Step 3: Deduct from multiple account if the invested amount is greater than the account balance
    # debugger
    if remaining_amount.positive?
      sorted_accounts = @accounts.sort_by { |account| account.id }
      sorted_accounts.each do |account|
        break if remaining_amount.zero?

        if (exact_account = @accounts.find { |acc| usable_balance(acc) == remaining_amount })
          adjust(exact_account, remaining_amount)
          remaining_amount = 0
          break
        else
          used_amount = [usable_balance(account), remaining_amount].min
          if used_amount.positive?
            adjust(account, used_amount)
            remaining_amount -= used_amount
          end
        end
      end
    end

    @no_match = remaining_amount.positive?
    render :index
  end

 
  private

  def find_exact_match(amount)
    @accounts.find { |account| usable_balance(account) == amount }
  end

  def find_greater_balance(amount)
    @accounts.find { |account| usable_balance(account) > amount }
  end

  def adjust(account, amount)
    @adjustments << { account: account, amount: amount }
  end

  def usable_balance(account)
    account.balance - (account.min_balance_enforced ? account.min_balance : 0)
  end
end
