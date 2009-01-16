# == Schema Information
# Schema version: 20081111111111
#
# Table name: bank_accounts
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  bank_name    :string(255)   
#  bank_code    :string(255)   not null
#  agency       :string(255)   
#  agency_code  :string(16)    not null
#  number       :string(32)    not null
#  key          :string(4)     not null
#  iban         :string(34)    not null
#  iban_text    :string(48)    not null
#  bic          :string(16)    
#  deleted      :boolean       not null
#  journal_id   :integer       not null
#  currency_id  :integer       not null
#  account_id   :integer       not null
#  company_id   :integer       not null
#  created_at   :datetime      not null
#  updated_at   :datetime      not null
#  created_by   :integer       
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class BankAccount < ActiveRecord::Base


 # before create a bank account, this computes automatically code iban.
 def before_validation
   self.iban = self.key + self.agency_code
   self.iban_text = self.iban
 end  
  



end
