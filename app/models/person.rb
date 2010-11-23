class Person < ActiveRecord::Base
  # Set default preferences
  before_validation do
    self.music ||= 'no_preference'
    self.smoking ||= 'no_preference'
  end

  validates :name, :presence => true
  validates :phone, :presence => true,
    :format => {:with => /^\(?\b([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/,
                :message => "must be a complete and numeric US phone number"}
  validates :address, :presence => true #, :mailing_address => true
  validates :music, :inclusion => {:in => ['no_preference', 'no_music', 'quiet_music', 'loud_music'],
    :message => "must be one of No Preference, No Music, Quiet Music, or Loud Music"}
  validates :smoking, :inclusion => {:in => ['no_preference', 'no_smoking', 'smoking'],
    :message => "must be one of No Preference, No Smoking, or Smoking"}

  # Process phone numbers
  after_validation do
    self.phone.gsub!(/^\(?\b([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/, '(\1) \2-\3')
  end

  has_and_belongs_to_many :arrangements, :join_table => "arrangements_passengers",
    :foreign_key => "passenger_id"
  has_many :organized_trips, :class_name => "Trip", :foreign_key => "organizer_id"
  has_and_belongs_to_many :trips, :join_table => "participants_trips",
    :foreign_key => "participant_id"
  has_and_belongs_to_many :pending_trips, :class_name => "Trip", :join_table => "invitees_trips",
    :foreign_key => "invitee_id"
  has_many :vehicles, :foreign_key => "owner_id"

  devise :database_authenticatable, :registerable, :validatable
  attr_accessible :email, :password, :password_confirmation, :name, :phone,
    :address, :city, :state, :music, :smoking

  def upcoming_trips
    self.trips.select {|trip| trip.upcoming?}
  end
end
