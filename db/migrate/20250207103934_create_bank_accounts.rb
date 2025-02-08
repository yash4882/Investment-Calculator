class CreateBankAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :bank_accounts do |t|
      t.decimal :balance
      t.boolean :min_balance_enforced
      t.decimal :min_balance

      t.timestamps
    end
  end
end
