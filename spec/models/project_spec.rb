require 'spec_helper'

describe Project do
  it "logo should be presence" do
    expect { create(:project) }.not_to raise_error
  end

  it "published default is false" do
    project = create(:project)
    expect(project.published).to be_false
  end

  it "logo_cache" do
    project = build(:project)
    project.where3 = ""
    expect(project.save).to be_false
    project.logo = nil
    project.where3 = "110011"
    expect(project.save).to be_true
  end

  describe "project user" do
    it "#add_owner #owner #member" do
      project = build(:project)
      owner = create(:user)
      project.add_owner(owner)
      expect(project.save).to be_true
      expect(project.owner).to eq(owner)
      expect(project.member(owner).user_id).to eq(owner.id)
      expect(project.member(owner).priv).to eq('owner')
    end
    
    it "users.size, project.size" do
      project = build(:project)
      owner = create(:user)
      project.add_owner(owner)
      project.save
      expect(owner.projects.size).to eq(1)
      expect(project.users.size).to eq(1)
    end
  end

  describe "#complete_degree" do
    pending
  end

  describe "#investor_users" do
    before do
      @project = build(:project)
      @owner = create(:user)
      @project.add_owner(@owner)
      @project.save!
      @owner.investor = build(:investor)
      @owner.save!
    end

    it "成功" do
      # 启动融资
      money_require = build(:money_require)
      @project.money_requires << money_require
      @project.save!
      money_require.start!

      investment = build(:investment_for_money)
      investment.investor_id = @owner.investor.id
      investment.money_require_id = money_require.id
      investment.save!

      expect(@project.investor_users.first.id).to eq( @owner.id )
    end

  end
end
