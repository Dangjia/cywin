class Investor < ActiveRecord::Base
  paginates_per 10

  searchable do
    text :name do
      user.name
    end

    text :description
    string :status
  end

  my_const_set(:INVESTOR_TYPES, [ :PERSON, :ORGANIZATION ])

  # status 标志是否开始审核, 并同时创建审核单
  state_machine :status, initial: :drafted do
    event :submit do
      transition [:drafted, :rejected] => :applied
    end
    
    event :reject do
      transition :applied => :rejected
    end

    event :pass do
      transition :applied => :passed
    end
  end

  belongs_to :user
  has_one :investidea

  # 领投人信息
  has_many :money_require, through: :leader_id

  validates :user_id, presence: true

  # basic info validates

  validates :phone, presence: true
  validates :investor_type, presence: true, inclusion: INVESTOR_TYPES
  validates :company, presence: true
  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 3 }

  scope :default_order, -> { order(created_at: :desc) }
  scope :passed, -> { where(status: 'passed') }

  has_one :card

  def pass_with_audit(note = nil)
    investor_audit = InvestorAudit.new
    investor_audit.note = note
    investor_audit.status = InvestorAudit::PASSED
    investor_audit.investor = self
    investor_audit.save!
    self.pass!
    self.user.add_role(:investor)
  end

  def reject_with_audit(note = nil)
    investor_audit = InvestorAudit.new
    investor_audit.note = note
    investor_audit.status = InvestorAudit::REJECTED
    investor_audit.investor = self
    investor_audit.save!
    self.reject!
    self.user.remove_role(:investor)
  end
end
