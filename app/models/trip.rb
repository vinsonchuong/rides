class Trip < ActiveRecord::Base
  after_initialize :initialize_nested_attributes

  validates :name, :presence => true
  validates :time, :presence => true, :timeliness => {:type => :datetime}
  validates :location, :presence => true
  validates :organizers, :has_trip_organizers => true

  has_many :arrangements, :dependent => :destroy
  belongs_to :location, :dependent => :destroy
  has_and_belongs_to_many :organizers, :class_name => "Person",
    :join_table => "organizers_trips", :association_foreign_key => "organizer_id"
  has_and_belongs_to_many :participants, :class_name => "Person",
    :join_table => "participants_trips", :association_foreign_key => "participant_id"
  has_many :invitations, :dependent => :destroy
  has_and_belongs_to_many :vehicles

  accepts_nested_attributes_for :location, :organizers

  def arrangement_for(person)
    return self.arrangements.select { |arrangement| arrangement.passengers.include?(person) }.first
  end

  def drivers
    return self.vehicles.map {|v| v.owner}
  end

  def driving?(person)
    return !(self.vehicles & person.vehicles).empty?
  end

  def vehicle_used?(vehicle)
    return self.vehicles.include?(vehicle)
  end

  def invitees
    self.invitations.map do |invitation|
      {
        :name => invitation.invitee,
        :email => invitation.email,
        :role => invitation.role
      }
    end
  end

  def roles_for(person)
    roles = Array.new
    roles << 'organizer' if self.organizers.include?(person)
    roles << 'participant' if self.participants.include?(person)
    return roles
  end

  def upcoming?
    return self.time >= Time.now()
  end

  def vehicle_for(person)
    return (self.vehicles & person.vehicles).first
  end

  def initialize_nested_attributes
    self.location ||= self.build_location
  end
end
