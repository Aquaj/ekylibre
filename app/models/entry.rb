# == Schema Information
# Schema version: 20081111111111
#
# Table name: entries
#
#  id              :integer       not null, primary key
#  record_id       :integer       not null
#  account_id      :integer       not null
#  name            :string(255)   not null
#  error           :string(255)   
#  currency_id     :integer       not null
#  currency_rate   :decimal(16, 6 not null
#  editable        :boolean       default(TRUE)
#  currency_debit  :decimal(16, 2 default(0.0), not null
#  currency_credit :decimal(16, 2 default(0.0), not null
#  debit           :decimal(16, 2 default(0.0), not null
#  credit          :decimal(16, 2 default(0.0), not null
#  intermediate_id :integer       
#  statement_id    :integer       
#  letter          :string(8)     
#  expired_on      :date          
#  position        :integer       
#  comment         :text          
#  company_id      :integer       not null
#  created_at      :datetime      not null
#  updated_at      :datetime      not null
#  created_by      :integer       
#  updated_by      :integer       
#  lock_version    :integer       default(0), not null
#


class Entry < ActiveRecord::Base
 
  after_destroy :update_record
  after_create  :update_record
  after_update  :update_record

  def before_validation 
    # computes the values depending on currency rate
    # for debit and credit.
   self.currency_rate = self.currency.rate if self.currency_rate.blank?
  
   if self.editable
     self.currency_debit = self.debit * self.currency_rate
     self.currency_credit = self.credit * self.currency_rate
   end
     
 end
  
 def validate
  errors.add_to_base lc(:error_amount_balance1) unless self.debit.zero? ^ self.credit.zero?     
  errors.add_to_base lc(:error_amount_balance2) unless self.debit + self.credit > 0    
  
  self.error = lc(:error_amount_balance1) unless self.debit.zero? ^ self.credit.zero?     
  self.error = lc(:error_amount_balance2) unless self.debit + self.credit > 0    
  
  #raise Exception.new "models:"+ self.errors.inspect.to_s  
 end
 
 # updates the amounts to the debit and the credit 
 # for the matching record.
 def update_record
   self.record.refresh
 end
 
 # this method allows to lock the entry. 
 def close
   Entry.update_all("editable = false", {:record_id => self.record.id})
 end
 
 
end
