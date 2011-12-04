# == Schema Information
#
# Table name: time_frames
#
#  id         :integer         not null, primary key
#  group_id   :integer
#  start_on   :date
#  end_on     :date
#  created_at :datetime
#  updated_at :datetime
#

class TimeFrame < ActiveRecord::Base
  validates_presence_of :group_id, :start_on, :end_on
  validate :ensure_end_on_is_after_start_on
  validate :validate_overlaps

  belongs_to :group

  def destroyable?
    # For now, every time_frame is destroyable
    true
  end

  private
  def ensure_end_on_is_after_start_on
    return if end_on.nil? || start_on.nil?
    errors.add(:end_at, 'deve ser maior que data inicial') if end_on <= start_on
  end

  def validate_overlaps
    return unless group

    time_frames = group.time_frames.reload
    if time_frames.any?{  |time_frame| ((time_frame.start_on..time_frame.end_on).to_a & (self.start_on..self.end_on).to_a).present? }
      errors.add :base, 'está conflitando com outro período'
    end
  end
end