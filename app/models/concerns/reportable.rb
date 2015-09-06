module Reportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, validate: false, as: :reportable
    before_destroy do |reportable|
      reportable.reports.each do |report|
       report.set(reportable: nil)
      end
    end
  end

  def close_open_reports!
    self.reports.where(open: true).each do |r|
      r.set(open: false, state: 'closed')
    end
  end
end
